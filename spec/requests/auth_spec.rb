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

  describe "Googleログインの既存ユーザー・失敗側" do
    before { OmniAuth.config.test_mode = true }

    it '既存ユーザー（provider/uid一致）はユーザーを増やさずログインできる' do
      existing = create(:user, provider: 'google_oauth2', uid: 'existing-uid', email: 'exist@example.com')
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
        provider: 'google_oauth2', uid: 'existing-uid',
        info: { name: existing.name, email: 'exist@example.com' }
      )

      expect { post '/users/auth/google_oauth2/callback' }.not_to change(User, :count)
      expect(response).to redirect_to('/posts/myindex')

      follow_redirect!
      expect(response).to be_successful
    end

    it '認証データが不正（invalid_credentials）ならユーザーは作られずログインされない' do
      OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
      # OmniAuthは失敗時にログ出力するため、テスト出力を汚さないよう黙らせる
      allow(OmniAuth.config).to receive(:logger).and_return(Logger.new(nil))

      expect { post '/users/auth/google_oauth2/callback' }.not_to change(User, :count)
      expect(response).not_to redirect_to('/posts/myindex')

      get myindex_posts_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "Googleログイン: メールが一致する既存ユーザーとの紐付け" do
    before { OmniAuth.config.test_mode = true }

    after do
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:google_oauth2] = nil
    end

    def mock_google(email_verified:)
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
        provider: 'google_oauth2', uid: 'attacker-uid',
        info: { name: '別人', email: 'owner@example.com', email_verified: email_verified }
      )
    end

    it 'メール検証済みなら既存ユーザーに紐付けてログインできる' do
      owner = create(:user, email: 'owner@example.com', provider: nil, uid: nil)
      mock_google(email_verified: true)

      expect { post '/users/auth/google_oauth2/callback' }.not_to change(User, :count)
      expect(owner.reload.uid).to eq('attacker-uid')
      expect(response).to redirect_to('/posts/myindex')
    end

    it 'メール未検証なら既存ユーザーに紐付けず、ログインもしない' do
      owner = create(:user, email: 'owner@example.com', provider: nil, uid: nil)
      mock_google(email_verified: false)

      expect { post '/users/auth/google_oauth2/callback' }.not_to change(User, :count)
      expect(owner.reload.uid).to be_nil
      expect(owner.provider).to be_nil
      expect(User.where(uid: 'attacker-uid')).to be_empty
      expect(response).to redirect_to(root_path)
    end
  end
end

RSpec.describe "ログイン開始・ログアウトのHTTPメソッド", type: :request do
  let(:user) { create(:user) }

  it 'ログアウトはDELETEで行い、ログアウト後はマイページに入れない' do
    sign_in user

    delete destroy_user_session_path
    expect(response).to redirect_to(root_path)

    get myindex_posts_path
    expect(response).to redirect_to(root_path)
  end

  it 'GETの/users/sign_outではログアウトされない' do
    sign_in user

    get "/users/sign_out"

    get myindex_posts_path
    expect(response).to be_successful
  end

  it 'ヘッダーのログアウトはDELETEを送るフォームとして描画される' do
    sign_in user

    get posts_path

    form = Nokogiri::HTML(response.body).at_css("form[action='#{destroy_user_session_path}']")
    expect(form).to be_present
    expect(form.at_css("input[name='_method']")["value"]).to eq("delete")
  end

  it 'Googleログインの開始はGETでは受け付けない' do
    get user_google_oauth2_omniauth_authorize_path

    expect(response.headers["Location"].to_s).not_to include("accounts.google.com")
  end

  it 'Googleログインの開始はPOSTならGoogleへリダイレクトする' do
    post user_google_oauth2_omniauth_authorize_path

    expect(response).to be_redirect
    expect(response.headers["Location"]).to start_with("https://accounts.google.com/")
  end
end
