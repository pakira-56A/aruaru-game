class GoogleLoginApiController < ApplicationController
  require 'googleauth/id_tokens/verifier'

  # g_csrf_tokenの検証がOKだった場合、callbackアクションが実行
  protect_from_forgery except: :callback
  # verify_g_csrf_tokenをメソッドを実行
  before_action :verify_g_csrf_token

  def callback
    payload = Google::Auth::IDTokens.verify_oidc(params[:credential], aud: ENV['GOOGLE_CLIENT_ID'])
    begin
      generated_password = Devise.friendly_token
      user = User.find_or_create_by!(email: payload['email']) do |u|
        u.password = generated_password
        u.name = payload['name']
      end
      sign_in(user)
      redirect_to after_login_path, notice: 'ログインできたよ'
    rescue StandardError => e
      pp e
    end
  end

  private

  def verify_g_csrf_token
    return unless cookies['g_csrf_token'].blank? || params[:g_csrf_token].blank? || cookies['g_csrf_token'] != params[:g_csrf_token]

    redirect_to root_path, notice: '不正なアクセスです'
  end
end
