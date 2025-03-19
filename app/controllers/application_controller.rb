class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_search
  protect_from_forgery with: :exception

  def handle_404
    flash[:alert] = "存在しないURLにアクセスしたみたいだよ"
    redirect_to posts_path
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  def set_search
    @q = Post.ransack(params[:q])
  end

  def after_sign_in_path_for(resource)
    myindex_posts_path
  end

  def custom_authenticate_user!
    return if user_signed_in?
    flash[:alert] = I18n.t("devise.failure.unauthenticated")
    redirect_to root_path
  end
end
