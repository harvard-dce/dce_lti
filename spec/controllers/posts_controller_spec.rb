describe PostsController do
  include DceLti::ConfigurationHelpers

  context 'unsuccessful authentication' do
    it 'redirects to the invalid_session path' do
      get :index

      expect(response).to redirect_to(DceLti::Engine.routes.url_helpers.invalid_sessions_path)
    end
    it 'redirects to "redirect_after_session_expire" url when it is a proc' do
      url = 'posts#signin'
      allow(controller).to receive(:canary_method)
      session_exp_url = ->(controller) do
        controller.canary_method
        url
      end

      with_overridden_lti_config_of(lti_config.merge(redirect_after_session_expire: session_exp_url)) do
        get :index

        expect(request).to redirect_to(url)
        expect(controller).to have_received(:canary_method)
      end
    end

  end

  context 'successful authentication' do
    before do
      user = double("User", id: "100")
      allow(DceLti::User).to receive(:find_by).and_return(user)
    end

    context 'index' do
      it 'is successful' do
        get :index

        expect(response).to be_successful
      end
    end

    context 'redirect_with_response_status' do
      it 'does not error and uses custom status' do
        get :redirect_with_response_status

        expect(response).to redirect_to(root_path)
        expect(response.status).to be 301
      end
    end
  end
end
