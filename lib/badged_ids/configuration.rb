module BadgedIds
  class Configuration
    CONFIG_DEFAULTS = {
      delimiter: "_",
      alphabet: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
      minimum_length: 24,
      implicit_order_column: nil,
      max_generation_attempts: 1,
      skip_uniqueness_check: false
    }.freeze

    OVERRIDABLE_CONFIGS_PER_MODEL = CONFIG_DEFAULTS.keys - %i[delimiter]

    attr_accessor(*CONFIG_DEFAULTS.keys)

    def initialize
      CONFIG_DEFAULTS.each { |key, value| instance_variable_set("@#{key}", value) }
    end

    def validate!
      %i[
        validate_delimiter
        validate_alphabet
        validate_alphabet_delimiter_combination
        validate_minimum_length
        validate_max_generation_attempts
      ].each { |method| send(method) }
      true
    end

    def to_h
      CONFIG_DEFAULTS.keys.each_with_object({}) { |key, hash| hash[key] = public_send(key) }
    end

    def reset_to_defaults!
      CONFIG_DEFAULTS.each { |key, value| public_send("#{key}=", value) }
    end

    private

    def validate_delimiter
      raise ConfigError, "Delimiter cannot be blank." if delimiter.to_s.strip.empty?
    end

    def validate_alphabet
      raise ConfigError, "Alphabet cannot be blank." if alphabet.to_s.strip.empty?
      raise ConfigError, "Alphabet must contain at least two unique characters." if alphabet.chars.uniq.size < 2
    end

    def validate_alphabet_delimiter_combination
      overlapping_chars = delimiter.chars & alphabet.chars
      return if overlapping_chars.empty?

      formatted_chars = overlapping_chars.map { |char| "`#{char}`" }.join(", ")
      raise ConfigError, "Alphabet and delimiter cannot share characters: #{formatted_chars}."
    end

    def validate_minimum_length
      raise ConfigError, "Minimum length must be greater than 0." if minimum_length < 1
    end

    def validate_max_generation_attempts
      raise ConfigError, "Max generation attempts must be greater than 0." if max_generation_attempts < 1
    end
  end
end
