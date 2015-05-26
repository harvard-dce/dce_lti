describe PostsController do
  context 'unsuccessful authentication' do
    it 'redirects to the invalid_session path' do
      get :index

      expect(response).to redirect_to(DceLti::Engine.routes.url_helpers.invalid_sessions_path)
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
