module DceLti
  describe ConfigsController do
    include ConfigurationHelpers

    context '#index' do
      it 'uses DceLti::Configurer to construct the tool config' do
        configurer_double = create_configurer_double

        get :index, { format: :xml, use_route: :dce_lti }

        expect(configurer_double).to have_received(:to_xml)
      end

      it 'renders XML' do
        create_configurer_double

        get :index, {format: :xml, use_route: :dce_lti }

        expect(response.content_type).to eq 'application/xml'
      end

      it 'defaults launch_url to sessions_url' do
        allow(Configurer).to receive(:new)
        create_configurer_double

        get :index, {format: :xml, use_route: :dce_lti }

        expect(Configurer).to have_received(:new).with(
          hash_including(launch_url: 'http://test.host/dce_lti/sessions')
        )
      end

      it 'passes in the correct variables' do
        url = 'foobar'

        with_overridden_lti_config_of({}) do |lti_config|
          create_configurer_double
          get :index, { format: :xml, use_route: :dce_lti }

          expect(Configurer).to have_received(:new).with(
            hash_including(
              domain: 'test.host',
              title: lti_config.provider_title,
              description: lti_config.provider_description,
              icon_url: lti_config.provider_icon_url,
              tool_id: lti_config.provider_tool_id,
            )
          )
        end
      end
    end

    def create_configurer_double
      double('LTI Configurer', to_xml: '<xml></xml>').tap do |configurer_double|
        allow(Configurer).to receive(:new).and_return(configurer_double)
      end
    end
  end
end
