Rails.application.routes.draw do
  #OmniAuth：認証成功時の処理
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  root "tops#index"
end
