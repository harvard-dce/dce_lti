module DceLti
  describe SessionsController do
    include ConfigurationHelpers

    context '#create' do
      it 'validates the timestamp' do
        timestamp="a timestamp"
        tool_provider = stub_successful_tool_provider
        allow(tool_provider).to receive(:oauth_timestamp).and_return(timestamp)

        allow(TimestampValidator).to receive(:valid?)

        post_to_create_with_params

        expect(tool_provider).to have_received(:oauth_timestamp)
        expect(TimestampValidator).to have_received(:valid?).with(timestamp)
      end

      it 'validates a nonce through DceLti::Nonce' do
        nonce = 'asdfasdf'
        tool_provider = stub_successful_tool_provider
        allow(tool_provider).to receive(:oauth_nonce).and_return(nonce)

        allow(Nonce).to receive(:valid?)

        post_to_create_with_params

        expect(tool_provider).to have_received(:oauth_nonce)
        expect(Nonce).to have_received(:valid?).with(nonce)
      end

      it 'uses a proc for consumer_key and consumer_secret if configured' do
        tool_provider = stub_successful_tool_provider
        consumer_key = 'a key'
        consumer_secret = 'a secret'

        consumer_key_proc = ->(launch_params) { consumer_key }
        consumer_secret_proc = ->(launch_params) { consumer_secret }

        with_overridden_lti_config_of(
          lti_config.merge(
            consumer_secret: consumer_secret_proc,
            consumer_key: consumer_key_proc
          )
        ) do

          post_to_create_with_params(oauth_consumer_key: consumer_key)

          expect(IMS::LTI::ToolProvider).to have_received(:new).with(
            consumer_key, consumer_secret, { 'oauth_consumer_key' => consumer_key }
          )
        end
      end

      it 'grabs the consumer_secret and consumer_key from rails configuration' do
        tool_provider = stub_successful_tool_provider
        consumer_key = 'consumer_key'
        consumer_secret = 'flubber'
        with_overridden_lti_config_of(
          lti_config.merge(
            consumer_secret: consumer_secret,
            consumer_key: consumer_key
          )
        ) do

          post_to_create_with_params(oauth_consumer_key: consumer_key)

          expect(IMS::LTI::ToolProvider).to have_received(:new).with(
            consumer_key, consumer_secret, { 'oauth_consumer_key' => consumer_key }
          )
        end
      end

      it 'validates a request' do
        stub_user_initializer
        tool_provider = stub_successful_tool_provider

        post_to_create_with_params

        expect(tool_provider).to have_received(:valid_request?)
      end

      context 'invalid LTI requests' do
        it 'renders :invalid' do
          stub_unsuccessful_tool_provider

          post_to_create_with_params

          expect(controller).to render_template(:invalid)
        end

        it 'does not touch the user model' do
          stub_unsuccessful_tool_provider
          allow(UserInitializer).to receive(:find_from)

          post_to_create_with_params

          expect(UserInitializer).not_to have_received(:find_from)
        end

        it 'does not store a user into the session' do
          stub_unsuccessful_tool_provider

          post_to_create_with_params

          expect(session.has_key?(:current_user_id)).to be false
        end
      end

      context 'valid LTI requests' do
        it 'redirects to "redirect_after_successful_auth" url when it is a proc' do
          url = '/sessions/create'
          after_auth_url = ->{ url }

          with_overridden_lti_config_of(lti_config.merge(redirect_after_successful_auth: after_auth_url)) do
            tool_provider = stub_successful_tool_provider

            post_to_create_with_params

            expect(request).to redirect_to(url)
          end
        end

        it 'finds or creates a user based the UserInitializer' do
          user = build_stubbed(:user)
          tool_provider = stub_successful_tool_provider
          allow(UserInitializer).to receive(:find_from).and_return(user)

          post_to_create_with_params(user_id: 'oauth_id')

          expect(UserInitializer).to have_received(:find_from).with(tool_provider)
        end

        it 'stores a user_id into the session' do
          user = build_stubbed(:user, id: 1001)
          tool_provider = stub_successful_tool_provider
          allow(UserInitializer).to receive(:find_from).and_return(user)

          post_to_create_with_params(user_id: 'asdfasdfasdfasfd')

          expect(session[:current_user_id]).to eq user.id
        end

        it 'stores resource and context related attributes on the session' do
          tool_provider = stub_successful_tool_provider
          allow(tool_provider).to receive_messages(captured_attributes)

          allow(UserInitializer).to receive(:find_from).and_return(build(:user))

          post_to_create_with_params

          captured_attributes.keys.each do |attribute|
            expect(session[attribute]).to eq captured_attributes[attribute]
          end
        end
      end
    end

    def stub_successful_tool_provider
      allow(TimestampValidator).to receive(:valid?).and_return(true)
      double(
        'Tool Provider',
        valid_request?: true,
        resource_link_id: 'resource_link_id',
        resource_link_title: 'resource_link_title',
        user_id: 'oauth_id',
        context_id: 'context_id',
        oauth_timestamp: "1413299813",
        roles: [],
      ).as_null_object.tap do |tool_provider|
        allow(IMS::LTI::ToolProvider).to receive(:new).and_return(tool_provider)
      end
    end

    def stub_user_initializer
      allow(UserInitializer).to \
        receive(:find_from).and_return(User.new(id: 100))
    end

    def stub_unsuccessful_tool_provider
      double('Tool Provider', valid_request?: false).tap do |tool_provider|
        allow(IMS::LTI::ToolProvider).to receive(:new).and_return(tool_provider)
      end
    end

    def post_to_create_with_params(params_to_merge = {})
      post :create, { use_route: :dce_lti }.merge(params_to_merge)
    end

    def captured_attributes
      {
        resource_link_id: 'a resource link id',
        resource_link_title: 'a resource link title',
        context_id: 'a context id',
        tool_consumer_instance_guid: 'guid',
        context_title: 'context title',
        context_label: 'context label',
      }
    end
  end
end
