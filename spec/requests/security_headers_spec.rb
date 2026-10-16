require 'rails_helper'

RSpec.describe "Content-Security-Policy", type: :request do
  let(:csp) do
    response.headers["Content-Security-Policy"]
  end

  it 'トップページでCSPヘッダーを返し、scriptとstyleはnonce付きで自サイトに限定する' do
    get root_path

    expect(response).to be_successful
    expect(csp).to be_present
    expect(csp).to include("default-src 'self'")
    expect(csp).to include("object-src 'none'")
    expect(csp).to match(/script-src 'self' [^;]*'nonce-[^']+'/)
    expect(csp).to match(/style-src 'self' [^;]*'nonce-[^']+'/)
  end

  it 'Google Analyticsの読み込み元を許可している' do
    get root_path

    expect(csp).to match(/script-src [^;]*https:\/\/www\.googletagmanager\.com/)
    expect(csp).to match(/connect-src [^;]*https:\/\/\*\.google-analytics\.com/)
  end

  it '画面遷移しても同じnonceを使う（Turboでの遷移でインラインが動くように）' do
    get root_path
    first_nonce = csp[/'nonce-([^']+)'/, 1]

    get policy_path
    expect(csp[/'nonce-([^']+)'/, 1]).to eq(first_nonce)
  end

  it 'トップページにインラインのイベントハンドラやjavascript: URLが無い' do
    get root_path

    expect(response.body).not_to match(/\son[a-z]+="/)
    expect(response.body).not_to include("javascript:")
  end

  it 'ゲーム画面にインラインのイベントハンドラやjavascript: URLが無い' do
    allow(OgpCreator).to receive(:build).and_return(nil)
    target = create(:post)

    get start_game_path(target)

    expect(response).to be_successful
    expect(response.body).not_to match(/\son[a-z]+="/)
    expect(response.body).not_to include("javascript:")
  end
end

RSpec.describe "ヘルスチェック", type: :request do
  it 'GET /up は200を返す' do
    get rails_health_check_path

    expect(response).to have_http_status(:ok)
  end
end
