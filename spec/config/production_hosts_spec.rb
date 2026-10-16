require 'rails_helper'
require 'open3'
require 'json'

# config.hosts / host_authorization は本番環境の設定にしか無いので、
# 本番環境として別プロセスで起動し、ミドルウェアを通した結果のステータスだけを確かめる。
RSpec.describe "本番環境で受け付けるHost", type: :config do
  let(:script) do
    <<~RUBY
      require "json"
      check = lambda do |url|
        env = Rack::MockRequest.env_for(url, "HTTPS" => "on", "HTTP_HOST" => URI(url).authority)
        Rails.application.call(env)[0]
      end
      puts JSON.dump(
        apex: check.call("https://aruaru-games.com/policy"),
        www: check.call("https://www.aruaru-games.com/policy"),
        render: check.call("https://example-app.onrender.com/policy"),
        other: check.call("https://other.example/policy"),
        up_other: check.call("https://10.0.0.1:10000/up")
      )
    RUBY
  end

  let(:statuses) do
    env = {
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
    expect(statuses["apex"]).not_to eq(403)
    expect(statuses["www"]).not_to eq(403)
    expect(statuses["render"]).not_to eq(403)
    expect(statuses["other"]).to eq(403)
    expect(statuses["up_other"]).to eq(200)
  end
end
