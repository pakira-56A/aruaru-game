Rails.application.routes.draw do
  #OmniAuth：認証成功時の処理
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  root "tops#toppage"

  post "google_login_api/callback", to: "google_login_api#callback"
  get "/after_login", to: "tops#my_index"

  get "/policy", to: "tops#policy"
  get "/term", to: "tops#term"
end
