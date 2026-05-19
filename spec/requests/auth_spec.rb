require 'rails_helper'

RSpec.describe "Auth", type: :request do

  describe "JWTセキュリティ検証" do
    it '空の秘密鍵で偽造されたJWTトークンを拒否すること' do
      expect {
        JWT.encode({ user_id: 1 }, "")
      }.to raise_error(JWT::DecodeError, /HMAC key cannot be empty/)
    end
  end

  describe "Google新規ログイン" do
    before do
      # OmniAuthをテストモードに切り替える
      OmniAuth.config.test_mode = true

      # Googleから返ってくる「新規ユーザー」の模擬データ（Mock）を設定
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
        provider: 'google_oauth2',
        uid: '99999999999999',
        info: { name: '新規 太郎',
                email: 'new_user@example.com'
        }
      })
    end

    after do
      # テスト終了後にモードをオフにする
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:google_oauth2] = nil
    end

    it '未登録のユーザーがGoogleログインした時、新しくユーザーが作成されてログインできること' do
      # テスト開始前に、このメールアドレスのユーザーがDBに存在しないことを確認
      expect(User.exists?(email: 'new_user@example.com')).to be_falsey
      # Googleログイン用コールバックURLにリクエストを送る
      post '/users/auth/google_oauth2/callback'
      # ユーザーがDBに新しく保存されてるか確認
      expect(User.exists?(email: 'new_user@example.com')).to be_truthy
      expect(response).to redirect_to('/posts/myindex')
    end
  end

end
