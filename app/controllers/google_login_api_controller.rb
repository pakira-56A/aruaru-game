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

      # 保存したURLがあればそこにリダイレクト、なければposts_pathに遷移
      redirect_to_location = stored_location_for(user) || posts_path
      # posts_pathに遷移するならメッセージを追加
      if redirect_to_location == posts_path
        flash[:notice] = 'ログインできたよ！どのあるあるで遊ぶ？'
      end
      redirect_to redirect_to_location
    rescue StandardError => e
      pp e
      redirect_to root_path, alert: 'ログインに失敗したよ。もう一度試してみてね！'
    end
  end

  private

  def verify_g_csrf_token
    return unless cookies['g_csrf_token'].blank? || params[:g_csrf_token].blank? || cookies['g_csrf_token'] != params[:g_csrf_token]

    redirect_to root_path, alert: '不正なアクセスです'
  end
end
