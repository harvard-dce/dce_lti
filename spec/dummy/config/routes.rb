Rails.application.routes.draw do
  mount DceLti::Engine => "/dce_lti"

  resources :posts, only: [:index] do
    collection do
      get :redirect_with_response_status
    end
  end

  root to: 'posts#index'
end
