class ApplicationController < ActionController::Base
  # deviseコントローラを使う前に、deviseコントローラーが真なら以下のアクションを実行する
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    # 情報更新時にnameの取得を許可
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
