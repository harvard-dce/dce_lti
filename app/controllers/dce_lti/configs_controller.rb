module DceLti
  class ConfigsController < ApplicationController
    skip_before_filter :authenticate_via_lti
    respond_to :xml

    def index
      tool_config = ::IMS::LTI::ToolConfig.new(
        launch_url: sessions_url,
        title: engine_config.provider_title,
        description: engine_config.provider_description,
      )

      if engine_config.respond_to?(:tool_config_extensions)
        engine_config.tool_config_extensions.call(self, tool_config)
      end

      respond_with tool_config
    end

    private

    def engine_config
      DceLti::Engine.config
    end
  end
end
