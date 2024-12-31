class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # google_oauth2アクションのCSRFチェックをスキップ
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  # GoogleのOAuthコールバックを処理
  def google_oauth2
    # OmniAuthから認証データを取得して、モデルのメソッドを呼び出す
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      # ユーザーが存在する場合はログインしてリダイレクト
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      # 新規ユーザーの保存が失敗した場合の処理
      session["devise.google_data"] = request.env["omniauth.auth"].except(:extra) # 不要なデータを削除
      redirect_to new_user_registration_url, alert: "Google認証に失敗したよ"
    end
  end

  def failure
    redirect_to posts_path
  end

  private

  def auth
    auth = request.env["omniauth.auth"]
  end
end
