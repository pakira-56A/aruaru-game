Rails.application.routes.draw do
  # トップページに移動する指示
  root "tops#index"

  get "tops/index"
end
