require 'rails_helper'

RSpec.describe "回数制限 (Rack::Attack)", type: :request do
  before do
    Rack::Attack.enabled = true
    Rack::Attack.cache.store.clear
    allow(OgpCreator).to receive(:build).and_return(nil)
    allow(Post).to receive(:find_or_create_from_openai).and_return(nil)
  end

  after { Rack::Attack.cache.store.clear }

  it 'OGP画像の生成は1分に20回を超えると429になる' do
    20.times { get images_ogp_path, params: { text: "a\nb" } }
    get images_ogp_path, params: { text: "a\nb" }
    expect(response).to have_http_status(:too_many_requests)
  end

  it '投稿ページの表示は1分に60回を超えると429になる' do
    post_record = create(:post)
    allow_any_instance_of(GamesController).to receive(:generate_ogp)
    60.times { get "/games/#{post_record.id}/start" }
    get "/games/#{post_record.id}/start"
    expect(response).to have_http_status(:too_many_requests)
  end

  it 'OpenAIの呼び出しは1分に5回を超えると429になる' do
    5.times { post "/openai_posts/answer", params: { question: "x" } }
    post "/openai_posts/answer", params: { question: "x" }
    expect(response).to have_http_status(:too_many_requests)
  end

  it 'ログイン開始は1分に10回を超えると429になる' do
    10.times { post "/users/auth/google_oauth2" }
    post "/users/auth/google_oauth2"
    expect(response).to have_http_status(:too_many_requests)
  end

  it '別のIPには影響しない' do
    20.times { get images_ogp_path, params: { text: "a" }, headers: { "REMOTE_ADDR" => "10.0.0.1" } }
    get images_ogp_path, params: { text: "a" }, headers: { "REMOTE_ADDR" => "10.0.0.2" }
    expect(response).not_to have_http_status(:too_many_requests)
  end
end
