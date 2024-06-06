Rails.application.routes.draw do
  # 元のメモ resources :tasks
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # 元のメモ get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  #　ここから編集
  # トップページに移動する指示
  root "tops#index"
end
