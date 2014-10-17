module DceLti
  module ConfigurationHelpers
    def with_overridden_lti_config_of(new_config)
      original_config = get_original_config(new_config)

      begin
        new_config.keys.each do |config_att|
          DceLti::Engine.config.send("#{config_att}=", new_config[config_att])
        end
        yield DceLti::Engine.config
      ensure
        new_config.keys.each do |config_att|
          DceLti::Engine.config.send("#{config_att}=", original_config[config_att])
        end
      end
    end

    def get_original_config(new_config)
      original_config = {}
      new_config.keys.each do |config_att|
        if ! DceLti::Engine.config.respond_to?(config_att)
          DceLti::Engine.config.send("#{config_att}=", nil)
        end
        original_config[config_att] = DceLti::Engine.config.send(config_att.to_sym)
      end
      original_config
    end

    def lti_config
      {
        provider_title: 'An awesome title',
        provider_description: 'A cool description',
      }
    end
  end
end
