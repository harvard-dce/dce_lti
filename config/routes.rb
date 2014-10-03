DceLti::Engine.routes.draw do
  resources :sessions, only: [:create] do
    collection do
      get :invalid
    end
  end

  resources :configs, only: [:index]
end
