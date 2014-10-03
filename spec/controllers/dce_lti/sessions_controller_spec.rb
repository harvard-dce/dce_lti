module DceLti
  describe SessionsController do
    include ConfigurationHelpers

    context '#create' do
      it 'grabs the secret from rails configuration' do
        tool_provider = stub_successful_tool_provider
        consumer_key = 'consumer_key'
        consumer_secret = 'flubber'
        with_overridden_lti_config_of(lti_config.merge(consumer_secret: consumer_secret)) do
          post :create, { oauth_consumer_key: consumer_key, use_route: :dce_lti }

          expect(IMS::LTI::ToolProvider).to have_received(:new).with(
            consumer_key, consumer_secret, { 'oauth_consumer_key' => consumer_key }
          )
        end
      end

      it 'validates a request' do
        stub_user_initializer
        tool_provider = stub_successful_tool_provider

        post :create, { use_route: :dce_lti }

        expect(tool_provider).to have_received(:valid_request?)
      end

      context 'invalid LTI requests' do
        it 'renders :invalid' do
          stub_unsuccessful_tool_provider

          post :create, { use_route: :dce_lti }

          expect(controller).to render_template(:invalid)
        end

        it 'does not touch the user model' do
          stub_unsuccessful_tool_provider
          allow(UserInitializer).to receive(:find_from)

          post :create, { use_route: :dce_lti }

          expect(UserInitializer).not_to have_received(:find_from)
        end

        it 'does not store a user into the session' do
          stub_unsuccessful_tool_provider

          post :create, { use_route: :dce_lti }

          expect(session.has_key?(:current_user_id)).to be false
        end
      end

      context 'valid LTI requests' do
        it 'redirects to "redirect_after_successful_auth" url when it is a proc' do
          url = '/sessions/create'
          after_auth_url = ->{ url }

          with_overridden_lti_config_of(lti_config.merge(redirect_after_successful_auth: after_auth_url)) do
            tool_provider = stub_successful_tool_provider

            post :create, { use_route: :dce_lti }

            expect(request).to redirect_to(url)
          end
        end

        it 'redirects to "redirect_after_successful_auth" url when it is a string' do
          after_auth_url = '/sessions/create'

          with_overridden_lti_config_of(lti_config.merge(redirect_after_successful_auth: after_auth_url)) do
            tool_provider = stub_successful_tool_provider

            post :create, { use_route: :dce_lti }

            expect(request).to redirect_to(after_auth_url)
          end
        end

        it 'finds or creates a user based the UserInitializer' do
          user = build_stubbed(:user)
          tool_provider = stub_successful_tool_provider
          allow(UserInitializer).to receive(:find_from).and_return(user)

          post :create, { user_id: 'oauth_id', use_route: :dce_lti }

          expect(UserInitializer).to have_received(:find_from).with(tool_provider)
        end

        it 'stores a user_id into the session' do
          user = build_stubbed(:user, id: 1001)
          tool_provider = stub_successful_tool_provider
          allow(UserInitializer).to receive(:find_from).and_return(user)

          post :create, { user_id: 'asdfasdfasdfasfd', use_route: :dce_lti  }

          expect(session[:current_user_id]).to eq user.id
        end

        it 'stores resource and context related attributes on the session' do
          tool_provider = stub_successful_tool_provider
          allow(tool_provider).to receive_messages(
            resource_link_id: 'a resource link id',
            resource_link_title: 'a resource link title',
            context_id: 'a context id'
          )
          allow(UserInitializer).to receive(:find_from).and_return(build(:user))

          post :create, { use_route: :dce_lti }

          expect(session[:resource_link_id]).to eq 'a resource link id'
          expect(session[:resource_link_title]).to eq 'a resource link title'
          expect(session[:context_id]).to eq 'a context id'
        end
      end
    end

    def stub_successful_tool_provider
      double(
        'Tool Provider',
        valid_request?: true,
        resource_link_id: 'resource_link_id',
        resource_link_title: 'resource_link_title',
        user_id: 'oauth_id',
        context_id: 'context_id',
        roles: []
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

  end
end
