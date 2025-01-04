module BadgedIds
  class BadgedId
    attr_reader :badge, :id_field, :config

    def initialize(model, badge, options = {})
      @badge = badge.to_s
      @id_field = options.fetch(:id_field, model.primary_key).to_s
      @config = build_config(options)
    end

    def generate_id
      validate!
      "#{badge}#{config.delimiter}#{generate_random_part}"
    end

    def validate!
      config.validate!
      validate_badge_delimiter_combination
      true
    end

    private

    def build_config(options)
      BadgedIds.config.dup.tap do |config|
        options.slice(*Configuration::OVERRIDABLE_CONFIGS_PER_MODEL).each do |key, value|
          config.public_send("#{key}=", value)
        end
      end
    end

    def generate_random_part
      SecureRandom.alphanumeric(config.minimum_length, chars: config.alphabet.chars)
    end

    def validate_badge_delimiter_combination
      overlapping_chars = badge.chars & config.delimiter.chars
      return if overlapping_chars.empty?

      formatted_chars = overlapping_chars.map { |char| "`#{char}`" }.join(", ")
      raise ConfigError, "Badge and delimiter cannot share characters: #{formatted_chars}."
    end
  end
end
