Rails.application.routes.draw do
  # OmniAuth：認証成功時の処理
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    # sessions: "users/sessions",
    registrations: "users/registrations" }

  devise_scope :user do
    post "users/auth/google_oauth2/callback", to: "users/omniauth_callbacks#google_oauth2"
    get "/users/sign_out" => "devise/sessions#destroy"
    get "/users/edit" => "users/registrations#edit", as: :edit_user_registration
    put "/users" => "users/registrations#update", as: :user_registration
  end

  root "tops#toppage"

  # post "google_login_api/callback", to: "google_login_api#callback"
  # get "/after_login", to: "tops#toppage" # アクセスされる時のため、一応残しています

  get "/policy", to: "tops#policy"
  get "/term", to: "tops#term"
  get "images/ogp.png", to: "images#ogp", as: "images_ogp"

  resources :posts, only: %i[index new create edit update destroy] do
    collection do
      get :myindex
    end
  end

  resources :tags, only: %w[index show destroy]

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
end
