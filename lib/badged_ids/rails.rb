require "badged_ids/badged_id"

module BadgedIds
  module Rails
    extend ActiveSupport::Concern

    included do
      class_attribute :_badged_id
    end

    class_methods do
      def has_badged_id(badge, **options)
        self._badged_id = BadgedId.new(self, badge, **options)
        Registry.register(badge, self)

        before_create { self[_badged_id.id_field] ||= self.class.generate_badged_id }

        if _badged_id.config.implicit_order_column.present? && implicit_order_column.nil?
          self.implicit_order_column = _badged_id.config.implicit_order_column
        end

        define_singleton_method(:generate_badged_id) do
          return _badged_id.generate_id if _badged_id.config.skip_uniqueness_check

          generated_ids = Set.new
          attempts = 0

          loop do
            generated_id = _badged_id.generate_id

            unless generated_ids.include?(generated_id)
              generated_ids.add(generated_id)
              return generated_id unless exists?(id: generated_id)
            end

            if (attempts += 1) >= _badged_id.config.max_generation_attempts
              raise Error, <<~MESSAGE.squish
                Failed to generate a unique badged ID within #{_badged_id.config.max_generation_attempts} attempts.
                Consider increasing the minimum length or the unique characters in the alphabet.
              MESSAGE
            end
          end
        end
      end
    end
  end
end
