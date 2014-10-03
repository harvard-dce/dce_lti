Rails.application.routes.draw do
  mount DceLti::Engine => "/dce_lti"

  resources :posts, only: [:index]

  root to: 'posts#index'
end
