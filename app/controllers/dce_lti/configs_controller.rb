module DceLti
  class ConfigsController < ApplicationController
    skip_before_filter :authenticate_via_lti
    respond_to :xml

    def index
      configurer = Configurer.new(
        domain: request.host,
        launch_url: launch_url,
        title: lti_config[:title],
        description: lti_config[:description],
        icon_url: lti_config[:icon_url],
        tool_id: lti_config[:tool_id],
      )

      respond_with configurer
    end

    private

    def lti_config
      Rails.application.config.lti_provider_configs
    end

    def launch_url
      if lti_config[:launch_url].respond_to?(:call)
        lti_config[:launch_url].call
      elsif lti_config[:launch_url]
        lti_config[:launch_url]
      else
        sessions_url
      end
    end
  end
end
