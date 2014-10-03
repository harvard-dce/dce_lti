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

    it 'is successful' do
      get :index

      expect(response).to be_successful
    end
  end
end
