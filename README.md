# Badged IDs

### Descriptive and Secure IDs for your Rails Models
[![Build Status](https://github.com/fabian12943/badged_ids/workflows/CI/badge.svg?cache-control=no-cache)](https://github.com/fabian12943/badged_ids/actions)

Badged IDs makes it simple to create descriptive and secure identifiers for your Rails
models.

By combining a badge with a randomly generated string, it helps you to prevent
[vulnerabilities associated with sequential IDs]() while keeping your IDs relatively short (e.g. compared to
[UUIDs](https://developer.mozilla.org/en-US/docs/Glossary/UUID)). Additionally,
it allows you to clearly identify the type of record, even when the ID is seen out of context,
enhancing both readability and traceability. 

#### Example:

```ruby
Order.create(/* ... */).id
# => "ord_24t6pjz7wpecix5"

Order.find("ord_24t6pjz7wpecix5")
# => #<Order id: "ord_24t6pjz7wpecix5", ...>

BadgedIds.find("ord_24t6pjz7wpecix5")
# => #<Order id: "ord_24t6pjz7wpecix5", ...>
```

The ID generation is highly configurable, enabling you to customize the badge, delimiter, length,
character set, and much more to suit your application’s needs.

Inspired by [Stripe's prefixed IDs](https://stripe.com/docs/api) and [Chris Oliver's prefixed_ids
gem](https://github.com/excid3/prefixed_ids).

## Installation

1. Add the following line to your app's `Gemfile`:

    ```ruby
    gem 'badged_ids'
    ```
2. Run the following command to install it:

    ```bash
    $ bundle install
    ```

## Usage

### Prerequisites

Ensure that the primary key of your model (typically `id`), or the field where you intend to store 
the badged ID, is of type string.

To set the primary key for a new table to a string, you can use the following migration:

```ruby
create_table :orders, id: :string do |t|
  # Add your columns here
end
```

If you like the generator to use string primary keys by default, add this to your `config/application.rb`:

```ruby
# config/application.rb
config.generators do |g|
  g.orm :active_record, primary_key_type: :string
end
```

### Basic Usage

To enable Badged IDs for your model, simplfy include the `has_badged_id` method and specify a badge
for your model. The badge is a short prefix that helps you to quickly identify the type of a record.

That's it! Now, whenever you create a new record, a unique Badged ID is automatically generated and
assigned to the primary key column of the record.

```ruby
class Order < ApplicationRecord
  has_badged_id :ord
end

Order.create(/* ... */).id
# => "ord_24t6pjz7wpecix5"
```

> [!NOTE]
> This basic setup uses the default configuration settings, but you can customize them
> *globally* or *per-model* to better suit your application's needs. For more information on configuring
> Badged IDs, refer to the [Configuration](#configuration) section.

### Find any record by Badged ID

You can easily find any record by its Badged ID using `BadgedIds.find`. Just provide the full badged ID (including the badge) to retrieve the corresponding record.

```ruby
BadgedIds.find("ord_24t6pjz7wpecix5")
# => #<Order id: "ord_24t6pjz7wpecix5", ...>

BadgedIds.find("usr_y0m4ud4iy94sq2y")
# => #<User id: "usr_y0m4ud4iy94sq2y", ...>
```

### Manually generate Badged IDs for a model

If you need to generate Badged IDs manually—such as when performing batch inserts or processing
records in bulk—you can use the `generate_badged_id` method.

```ruby
Order.generate_badged_id
# => "ord_24t6pjz7wpecix5"
```

## Configuration

### Global Configuration

Various configuration options are available to adjust the behavior to your application's needs. 
You can define global settings by creating or modifying the `config/initializers/badged_ids.rb` file 
in your Rails application.

#### Example

```ruby
# config/initializers/badged_ids.rb
BadgedIds.config do |config|
  config.alphabet = "abc123"
  config.delimiter = "-"
  config.minimum_length = 20
  config.max_generation_attempts = 3
  config.skip_uniqueness_check = false
  config.implicit_order_column = :created_at
end 
```

#### Available Configuration Options

The table below details all available configuration options and their default values:

| Config                   | Description                                                                   | Default                                  |
| ------------------------ | ----------------------------------------------------------------------------- | ---------------------------------------- |
| alphabet                 | Characters used to generate the random part of the ID.                        | `"abcdefghijklmnopqrstuvwxyz0123456789"` |
| delimiter                | String separating the badge from the random string in the ID.                 | `"_"`                                    |
| minimum_length           | Length of the random part of the ID, excluding the badge and delimiter.       | `15`                                     |
| max_generation_attempts¹ | Maximum attempts to generate a unique ID before raising an error.             | `1`                                      |
| skip_uniqueness_check²   | Skip uniqueness check and retry mechanism when generating a new ID.           | `false`                                  |
| implicit_order_column    | Default column used for ordering records of model, if not explicitly defined. | `nil`                                    |

¹ It is recommended to leave this value as-is. If you encounter collisions, it's likely that the
`minimum_length` is too short and/or the `alphabet` contains too few unique characters. 
When configured properly, the chances of a collision are virtually zero. 
If you're uncertain, it's best to stick with the default values.

² You can skip the uniqueness check if you're confident that the combination of `minimum_length` 
and `alphabet` ensures that collisions are virtually impossible. This improves performance when creating thousands 
of records at once (see [Benchmarks](#benchmarks)).

### Model Overrides

When defining a model with `has_badged_id`, you can override specific settings for that model. These
options allow you to fine-tune the ID generation without affecting the global configuration.

#### Example

```ruby
class Order < ApplicationRecord
  has_badged_id :ord, id_field: :public_id, alphabet: "ABCDEF0123456789", minimum_length: 20
end

Order.create(/* ... */).public_id
# => "ord_E19D5E5ADB476416C1F6"
```

#### Available Model Overrides

The table below details all available options that can be overridden on a per-model basis and their default values:

| Option                  | Description                                                               |  Default                             |
| ----------------------- | ----------------------------------------------------------------------------- | ---------------------------------- |
| id_field                | Database field used for storing the ID. Must be of type `string`.             | `model.primary_key` (usually `id`) |
| alphabet                | Characters used to generate the random part of the ID.                        | `config.alphabet`                  |
| minimum_length          | Length of the random part of the ID, excluding the badge and delimiter.       | `config.minimum_length`            |
| max_generation_attempts | Maximum attempts to generate a unique ID before raising an error.             | `config.max_generation_attempts`   |
| skip_uniqueness_check   | Skip uniqueness check and retry mechanism when generating a new ID.           | `config.skip_uniqueness_check`     |
| implicit_order_column   | Default column used for ordering records of model, if not explicitly defined. | `config.implicit_order_column`     |

### Configuration Validation

Both global and model-specific configurations are validated at two critical points: during 
application startup and immediately before generating a new ID. If any configuration is invalid, 
an error is raised with a detailed message on how to resolve the issue.

## Benchmarks

The following benchmarks compare the performance of Badged IDs with other common ID generation
methods when creating 20,000 simple records on my local machine.

|                                               | user      | system   | total     | real      |
| --------------------------------------------- | --------- | -------- | --------- | --------- |
| Sequential integer id                         | 15.266384 | 1.211182 | 16.477566 | 21.128873 |
| UUIDv4                                        | 15.324471 | 1.315743 | 16.640214 | 21.262059 |
| Badged ID<br>(`skip_uniqueness_check: true`)  | 15.898291 | 1.245899 | 17.144190 | 21.599303 |
| Badged ID<br>(`skip_uniqueness_check: false`) | 22.520556 | 1.696816 | 24.217372 | 30.400110 |

### Conclusion

When using Badged IDs with `skip_uniqueness_check: true`, the performance is slightly slower than 
that of sequential integer IDs or UUIDs, but the difference is minimal. This configuration is ideal
when the `alphabet` and `minimum_length` ensure that collisions are virtually impossible.

When using Badged IDs with `skip_uniqueness_check: false`, the performance is notably slower
than that of sequential integer IDs or UUIDs. This configuration is only recommended when the risk 
of collision is a realistic concern due to a short `alphabet` and/or `minimum_length` that, for 
whatever reason, cannot be adjusted. In such cases, verifying the uniqueness of the generated ID 
before saving and retrying in the event of a collision becomes necessary.

For most use cases, especially when not creating thousands of records at once,
the performance impact is negligible, regardless of the `skip_uniqueness_check` config.
