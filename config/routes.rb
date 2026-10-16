Rails.application.routes.draw do
  # ログインはGoogleのみ。メール+パスワードのログイン画面（sessions#new/create）は使わないので、
  # セッション系は既定のルートを作らず、ログアウト（DELETE）だけを下で定義する。
  devise_for :users, skip: :sessions, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations" }

  devise_scope :user do
    post "users/auth/google_oauth2/callback", to: "users/omniauth_callbacks#google_oauth2"
    delete "/users/sign_out" => "devise/sessions#destroy", as: :destroy_user_session
    get "/users/edit" => "users/registrations#edit", as: :edit_user_registration
    put "/users" => "users/registrations#update", as: :user_registration
  end

  # Renderのヘルスチェック用（起動して例外なく応答できれば200）
  get "up" => "rails/health#show", as: :rails_health_check

  root "tops#toppage"

  get "/after_login", to: "tops#toppage" # アクセスされる時のため、一応残しています

  get "/policy", to: "tops#policy"
  get "/term", to: "tops#term"
  get "images/ogp.png", to: "images#ogp", as: "images_ogp"

  resources :posts, only: %i[index new create edit update destroy] do
    collection do
      get :myindex
    end
  end

  resources :tags, only: %w[index show] do
    collection do
      get :myindex
    end
  end
  resources :likes, only: %i[index create destroy]

  resources :search_posts, only: [] do
    collection do
      get :search
      get :autocomplete
    end
  end

  resources :games, only: [] do
    member do
      get "start"
    end
  end

  resources :openai_posts, only: [] do
    collection do
      post :answer
    end
  end

  match "*path", to: "application#handle_404", via: :all
end
