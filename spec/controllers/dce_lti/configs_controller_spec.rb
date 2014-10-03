describe DceLti::ConfigsController do
  include DceLti::ConfigurationHelpers
  include Rails.application.routes.url_helpers

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
      allow(DceLti::Configurer).to receive(:new)
      create_configurer_double

      get :index, {format: :xml, use_route: :dce_lti }

      expect(DceLti::Configurer).to have_received(:new).with(
        hash_including(launch_url: 'http://test.host/dce_lti/sessions')
      )
    end

    it 'passes in the correct variables' do
      url = 'foobar'
      launch_url = ->{ url }

      with_overridden_lti_config_of(lti_config.merge(launch_url: launch_url)) do |lti_config|
        create_configurer_double
        get :index, { format: :xml, use_route: :dce_lti }

        expect(DceLti::Configurer).to have_received(:new).with(
          domain: 'test.host',
          launch_url: url,
          title: lti_config[:title],
          description: lti_config[:description],
          icon_url: lti_config[:icon_url],
          tool_id: lti_config[:tool_id],
        )
      end
    end

    it 'handles a string launch_url' do
      launch_url = 'foobar'

      with_overridden_lti_config_of(lti_config.merge(launch_url: launch_url)) do |lti_config|
        create_configurer_double
        get :index, { format: :xml, use_route: :dce_lti }

        expect(DceLti::Configurer).to have_received(:new).with(
          hash_including(launch_url: launch_url)
        )
      end
    end
  end

  def create_configurer_double
    double('LTI Configurer', to_xml: '<xml></xml>').tap do |configurer_double|
      allow(DceLti::Configurer).to receive(:new).and_return(configurer_double)
    end
  end
end
