require 'ims/lti'
require 'pg'
require 'p3p'

module DceLti
  class Engine < ::Rails::Engine
    def self.setup
      config.copy_launch_attributes_to_session = %i|
context_id
context_label
context_title
resource_link_id
resource_link_title
tool_consumer_instance_guid
launch_presentation_return_url
      |

      config.enable_cookieless_sessions = false

      config.provider_title = (ENV['LTI_PROVIDER_TITLE'] || 'DCE LTI Provider')
      config.provider_description = (ENV['LTI_PROVIDER_DESCRIPTION'] || 'A description of this')

      config.redirect_after_successful_auth = -> (controller) do
        session_key_name = Rails.application.config.session_options[:key]
        Rails.application.routes.url_helpers.root_path(session_key_name => controller.session.id)
      end

      config.tool_config_extensions = ->(*) {}
      yield config
    end

    initializer 'dce_lti.load_helpers' do
      ActionController::Base.send :include, ControllerMethods
      ActionController::Base.send :include, RedirectToHelper
      ActionController::Base.send :helper, RedirectToHelper
      ApplicationController.skip_before_filter :verify_authenticity_token, if: :cookieless_session?
    end

    initializer 'dce_lti.add_middleware' do |app|
      if config.enable_cookieless_sessions
        app.middleware.insert_before ActionDispatch::Cookies, 'DceLti::Middleware::CookieShim'
        app.middleware.use 'DceLti::Middleware::CookielessSessions'
      end
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
