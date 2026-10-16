require 'rails_helper'
require 'open3'
require 'json'

# config.hosts / host_authorization は本番環境の設定にしか無いので、
# 本番環境として別プロセスで起動し、ミドルウェアを通した結果のステータスだけを確かめる。
RSpec.describe "本番環境で受け付けるHost", type: :config do
  # 描画を伴わない経路（存在しないURL → 一覧へのリダイレクト）で、Hostの検査だけを確かめる
  let(:script) do
    <<~RUBY
      require "json"
      check = lambda do |url|
        env = Rack::MockRequest.env_for(url, "HTTPS" => "on", "HTTP_HOST" => URI(url).authority)
        Rails.application.call(env)[0]
      end
      puts JSON.dump(
        apex: check.call("https://aruaru-games.com/no-such-page"),
        www: check.call("https://www.aruaru-games.com/no-such-page"),
        render: check.call("https://example-app.onrender.com/no-such-page"),
        other: check.call("https://other.example/no-such-page"),
        up_other: check.call("https://10.0.0.1:10000/up")
      )
    RUBY
  end

  # 本番設定の database.yml は DATABASE_URL 前提なので、テスト用DBの接続先を渡す
  let(:database_url) do
    ENV["DATABASE_URL"].presence || begin
      c = ActiveRecord::Base.connection_db_config.configuration_hash
      "postgres://#{c[:username]}:#{c[:password]}@#{c[:host]}:#{c[:port] || 5432}/#{c[:database]}"
    end
  end

  let(:statuses) do
    env = {
      "DATABASE_URL" => database_url,
      "RAILS_ENV" => "production",
      "SECRET_KEY_BASE_DUMMY" => "1",
      "RENDER_EXTERNAL_HOSTNAME" => "example-app.onrender.com",
      "OPENAI_API_KEY" => "dummy",
      "RAILS_LOG_LEVEL" => "fatal"
    }
    out, err, status = Open3.capture3(env, "bin/rails", "runner", script, chdir: Rails.root.to_s)
    raise "runner failed: #{err}" unless status.success?

    JSON.parse(out.lines.last)
  end

  it '独自ドメイン（www有無）とRenderのホスト名は受け付け、それ以外は403、/upはHostに関係なく200' do
    expect(statuses["apex"]).to be_between(200, 399)
    expect(statuses["www"]).to be_between(200, 399)
    expect(statuses["render"]).to be_between(200, 399)
    expect(statuses["other"]).to eq(403)
    expect(statuses["up_other"]).to eq(200)
  end
end
