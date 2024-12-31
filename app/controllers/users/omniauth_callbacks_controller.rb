class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # google_oauth2アクションのCSRFチェックをスキップ
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  # GoogleのOAuthコールバックを処理
  def google_oauth2
    # OmniAuthから認証データを取得して、モデルのメソッドを呼び出す
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      # 既存ユーザーは、ログインしてリダイレクト
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success) if is_navigational_format?
    else
      if @user.save    # 新規ユーザー、保存成功時
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success) if is_navigational_format?
      else
        session["devise.google_data"] = request.env["omniauth.auth"].except(:extra)
        redirect_to root_path, alert: "Google認証に失敗したよ"
      end
    end
  end

  def failure
    redirect_to root_path
  end

  private

  def auth
    request.env["omniauth.auth"]
  end
end
