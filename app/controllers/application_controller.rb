class ApplicationController < ActionController::Base
  # deviseコントローラを使う前に、deviseコントローラーが真なら以下のアクションを実行する
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_search

  private

  def configure_permitted_parameters
    # 情報更新時にnameの取得を許可
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  def set_search
    @q = Post.ransack(params[:q])
  end

  def after_sign_in_path_for(resource)
    posts_path # リダイレクト先をダッシュボードに変更
  end
end
