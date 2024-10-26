Rails.application.routes.draw do
  devise_for :users
  # トップページに移動する指示
  root "tops#index"

  get "tops/index"
end
