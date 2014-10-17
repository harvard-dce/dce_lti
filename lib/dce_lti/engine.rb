require 'ims/lti'
require 'pg'

module DceLti
  class Engine < ::Rails::Engine
    def self.setup
      config.provider_title = (ENV['LTI_PROVIDER_TITLE'] || 'DCE LTI Provider')
      config.provider_description = (ENV['LTI_PROVIDER_DESCRIPTION'] || 'A description of this')

      config.redirect_after_successful_auth = -> do
        Rails.application.routes.url_helpers.root_path
      end
      config.tool_config_extensions = ->(*) {}
      yield config
    end

    initializer 'dce_lti.load_helpers' do
      ActionController::Base.send :include, ControllerMethods
    end

    isolate_namespace DceLti

    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
