class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # google_oauth2アクションのCSRFチェックをスキップ
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  # GoogleのOAuthコールバックを処理
  def google_oauth2
    # callback_for(:google)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    # if @user.persisted?
    #   sign_in_and_redirect @user, event: :authentication
    #   set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    # else
    #   session["devise.google_data"] = request.env["omniauth.auth"].except("extra")
    #   redirect_to posts_path, alert: @user.errors.full_messages.join("\n")
    # end

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
      # redirect_to posts_path, notice: "ログインできたよ！どのあるあるで遊ぶ？"
    else
      # ユーザーが存在しない場合の処理
      generated_password = Devise.friendly_token
      @user = User.find_or_create_by!(email: request.env["omniauth.auth"]["info"]["email"]) do |u|
        u.password = generated_password
        u.name = request.env["omniauth.auth"]["info"]["name"]
      end
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
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
