Rails.application.routes.draw do
  #OmniAuth：認証成功時の処理
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  root "tops#toppage"

  post "google_login_api/callback", to: "google_login_api#callback"
  get "/after_login", to: "tops#toppage" #アクセスされる時のため、一応残しています

  get "/policy", to: "tops#policy"
  get "/term", to: "tops#term"

  resources :posts, only: %i[index new create show edit update destroy] do
    collection do
      get :myindex
    end
  end

  resources :games, only: [] do
    member do
      get "start"
    end
  end

end
