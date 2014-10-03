module DceLti
  class SessionsController < ApplicationController
    require 'oauth/request_proxy/rack_request'
    skip_before_filter :verify_authenticity_token, :authenticate_via_lti

    def create
      tool_provider = IMS::LTI::ToolProvider.new(
        consumer_key, consumer_secret, launch_params
      )

      if tool_provider.valid_request?(request)
        user = UserInitializer.find_from(tool_provider)
        session[:current_user_id] = user.id
        session.merge!(captured_attributes_from(tool_provider))
        redirect_to redirect_after_successful_auth
      else
        render :invalid
      end
    end

    private

    def launch_params
      params.reject{ |k,v| ['controller','action'].include? k }
    end

    def consumer_key
      params[:oauth_consumer_key]
    end

    def redirect_after_successful_auth
      url = Rails.application.config.lti_provider_configs[:redirect_after_successful_auth]
      if url.respond_to?(:call)
        url.call
      elsif url.present?
        url
      else
        Rails.application.routes.url_helpers.root_path
      end
    end

    def consumer_secret
      Rails.application.config.lti_provider_configs[:consumer_secret]
    end

    def captured_attributes_from(tool_provider)
      [
        :resource_link_id, :resource_link_title, :context_id
      ].inject({}) do |attributes, att|
        attributes.merge(att => tool_provider.send(att))
      end
    end
  end
end
