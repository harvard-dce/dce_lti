module DceLti
  class Configurer
    def initialize(
      domain: '',
      launch_url: '',
      title: '',
      description: '',
      icon_url: '',
      tool_id: ''
    )
      @tool_config = ::IMS::LTI::ToolConfig.new(title: title, launch_url: launch_url)
      tool_config.extend ::IMS::LTI::Extensions::Canvas::ToolConfig
      tool_config.description = description
      tool_config.canvas_privacy_anonymous!
      tool_config.canvas_domain!(domain)
      tool_config.canvas_icon_url!(icon_url)
      tool_config.canvas_text!(title)
      tool_config.set_ext_param('canvas.instructure.com', :tool_id, tool_id)
    end

    def to_xml(*)
      tool_config.to_xml
    end

    private

    attr_reader :tool_config
  end
end
