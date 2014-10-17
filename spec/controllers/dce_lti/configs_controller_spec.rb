module DceLti
  describe ConfigsController do
    include ConfigurationHelpers

    context '#index' do
      it 'uses IMS::LTI::ToolConfig to construct the tool config' do
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
        sessions_url = 'foobar'
        allow(controller).to receive(:sessions_url).and_return(sessions_url)
        create_configurer_double

        get :index, {format: :xml, use_route: :dce_lti }

        expect(IMS::LTI::ToolConfig).to have_received(:new).with(
          hash_including(launch_url: sessions_url)
        )
        expect(controller).to have_received(:sessions_url)
      end

      it 'evaluates custom lambdas with controller context correctly' do
        tool_config_extensions = ->(controller, tool_config) {
          tool_config.extend ::IMS::LTI::Extensions::Canvas::ToolConfig
          tool_config.canvas_domain!(controller.request.host)
        }
        with_overridden_lti_config_of({tool_config_extensions: tool_config_extensions}) do
          get :index, { format: :xml, use_route: :dce_lti }
          expect(response.body).to include 'test.host'
        end
      end

      it 'passes in the correct variables' do
        with_overridden_lti_config_of({}) do |lti_config|
          create_configurer_double
          get :index, { format: :xml, use_route: :dce_lti }

          expect(IMS::LTI::ToolConfig).to have_received(:new).with(
            hash_including(
              title: lti_config.provider_title,
              description: lti_config.provider_description,
            )
          )
        end
      end
    end

    def create_configurer_double
      double(
        'IMS::LTI::ToolConfig',
        to_xml: '<xml></xml>',
        set_ext_param: '',
      ).tap do |configurer_double|
        allow(IMS::LTI::ToolConfig).to receive(:new).and_return(configurer_double)
      end
    end
  end
end
