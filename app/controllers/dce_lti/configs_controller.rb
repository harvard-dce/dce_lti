module DceLti
  class ConfigsController < ApplicationController
    skip_before_filter :authenticate_via_lti
    respond_to :xml

    def index
      configurer = Configurer.new(
        domain: request.host,
        launch_url: sessions_url,
        title: engine_config.provider_title,
        description: engine_config.provider_description,
        icon_url: engine_config.provider_icon_url,
        tool_id: engine_config.provider_tool_id,
      )

      respond_with configurer
    end

    private

    def engine_config
      DceLti::Engine.config
    end
  end
end
