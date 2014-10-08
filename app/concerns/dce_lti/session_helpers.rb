module DceLti
  module SessionHelpers
    ATTRIBUTES_TO_EXTRACT_FOR_SESSION = %i|
context_id
context_label
context_title
resource_link_id
resource_link_title
tool_consumer_instance_guid
    |

    def valid_lti_request?(request)
      tool_provider.valid_request?(request) &&
        Nonce.valid?(tool_provider.oauth_nonce) &&
        TimestampValidator.valid?(tool_provider.oauth_timestamp)
    end

    def launch_params
      params.reject{ |k,v| ['controller','action'].include? k }
    end

    def consumer_key
      find_from_config(:consumer_key)
    end

    def consumer_secret
      find_from_config(:consumer_secret)
    end

    def find_from_config(attribute)
      value = Engine.config.send(attribute)
      if value.respond_to?(:call)
        value.call(launch_params)
      else
        value
      end
    end

    def redirect_after_successful_auth
      Engine.config.redirect_after_successful_auth.call
    end

    def tool_provider
      @tool_provider ||= IMS::LTI::ToolProvider.new(
        consumer_key, consumer_secret, launch_params
      )
    end

    def captured_attributes_from(tool_provider)
      ATTRIBUTES_TO_EXTRACT_FOR_SESSION.inject({}) do |attributes, att|
        attributes.merge(att => tool_provider.send(att))
      end
    end
  end
end
