require "badged_ids/version"
require "badged_ids/railtie"
require "badged_ids/errors"
require "badged_ids/registry"
require "badged_ids/rails"
require "badged_ids/configuration"

module BadgedIds
  @config = Configuration.new

  class << self
    def config
      if block_given?
        yield @config
        @config.validate!
      else
        @config
      end
    end

    def find(badged_id)
      badge, _id = split_id(badged_id)
      Registry.find_model(badge).find(badged_id)
    end

    private

    def split_id(badged_id, delimiter = config.delimiter)
      badge, _, id = badged_id.to_s.rpartition(delimiter)
      [ badge, id ]
    end
  end
end
