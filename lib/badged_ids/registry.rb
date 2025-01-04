module BadgedIds
  class Registry
    mattr_accessor :models, default: {}

    class << self
      def register(badge, model)
        badge = badge.to_s
        if models.key?(badge) && models[badge] != model
          raise RegistryError, "Badge `#{badge}` is already assigned to `#{models[badge]}`."
        end

        models[badge] = model
      end

      def find_model(badge)
        models.fetch(badge.to_s) do
          raise RegistryError, <<~MESSAGE.squish
            No model with the badge `#{badge}` registered.
            Available badges are: #{registered_badges.join(", ")}.
          MESSAGE
        end
      end

      def registered_badges
        models.keys
      end
    end
  end
end
