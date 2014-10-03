module DceLti
  module ConfigurationHelpers
    def with_overridden_lti_config_of(new_config)
      existing_config = Rails.application.config.lti_provider_configs
      begin
        Rails.application.config.lti_provider_configs = new_config
        yield Rails.application.config.lti_provider_configs
      ensure
        Rails.application.config.lti_provider_configs = existing_config
      end
    end

    def lti_config
      {
        title: 'An awesome title',
        description: 'A cool description',
        icon_url: 'http://www.example.com/icon.png',
        tool_id: '123123123'
      }
    end
  end
end
