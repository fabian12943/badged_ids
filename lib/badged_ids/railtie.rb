module BadgedIds
  class Railtie < ::Rails::Railtie
    initializer "badged_ids.extend_active_record" do
      ActiveSupport.on_load(:active_record) do
        include BadgedIds::Rails
      end
    end
  end
end
