class ApplicationController < ActionController::Base
  # deviseコントローラを使う前に、deviseコントローラーが真なら以下のアクションを実行する
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_search
  protect_from_forgery with: :exception

  private

  def configure_permitted_parameters
    # 情報更新時にnameの取得を許可
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  def set_search
    @q = Post.ransack(params[:q])
  end

  def after_sign_in_path_for(resource)
    posts_path
  end

  # 未ログイン状態でログイン必須ページにアクセスした際の処理
  def custom_authenticate_user!
    return if user_signed_in?
    flash[:alert] = I18n.t("devise.failure.unauthenticated")
    redirect_to root_path
  end
end
