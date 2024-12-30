class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # google_oauth2アクションのCSRFチェックをスキップ
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  # GoogleのOAuthコールバックを処理
  def google_oauth2
    # callback_for(:google)

    # @user = User.from_omniauth(request.env["omniauth.auth"])
    # if @user.persisted?
    #   sign_in_and_redirect @user, event: :authentication
    #   set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    # else
    #   session["devise.google_data"] = request.env["omniauth.auth"].except("extra")
    #   redirect_to posts_path, alert: @user.errors.full_messages.join("\n")
    # end

    # OmniAuthから認証データを取得
    auth = request.env["omniauth.auth"]

    # ユーザーを検索または初期化
    @user = User.find_or_initialize_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      # user.password = nil           # パスワードを設定しない
      # user.password_confirmation = nil
      # user.skip_password_validation # パスワード検証をスキップ
    end
  
    if @user.persisted? || @user.save
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      redirect_to new_user_registration_url, alert: "Googleログインに失敗しました。"
    end
  end

  # ユーザーをOAuth情報から作成・取得
  # def callback_for(provider)
  #   @user = User.from_omniauth(request.env["omniauth.auth"])

  #   if @user.persisted?
  #     sign_in_and_redirect @user, event: :authentication
  #     set_flash_message(:notice, :success, kind: provider.to_s.capitalize) if is_navigational_format?
  #   else
  #     flash[:alert] = @user.errors.full_messages.to_sentence if @user.errors.any?
  #     session["devise.#{provider}_data"] = request.env["omniauth.auth"].except(:extra)
  #     redirect_to new_user_registration_url
  #   end
  # end

  def failure
    redirect_to posts_path
  end

  private

  def auth
    auth = request.env['omniauth.auth']
  end
end
