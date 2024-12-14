Rails.application.routes.draw do
  # OmniAuth：認証成功時の処理
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations" }

  devise_scope :user do
    get "/users/sign_out" => "devise/sessions#destroy"
  end

  root "tops#toppage"

  post "google_login_api/callback", to: "google_login_api#callback"
  get "/after_login", to: "tops#toppage" # アクセスされる時のため、一応残しています

  get "/policy", to: "tops#policy"
  get "/term", to: "tops#term"
  get "images/ogp.png", to: "images#ogp", as: "images_ogp"

  resources :posts, only: %i[index new create show edit update destroy] do
    collection do
      get :myindex
    end
  end

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
