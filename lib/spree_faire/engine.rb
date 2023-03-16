module SpreeFaire
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_faire'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'spree_faire.environment', before: :load_config_initializers do |_app|
    end
    
    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end
    
    Spree::PermittedAttributes.store_attributes << :faire_api_key
    Spree::PermittedAttributes.store_attributes << :user_id

    config.to_prepare(&method(:activate).to_proc)
  end
end
