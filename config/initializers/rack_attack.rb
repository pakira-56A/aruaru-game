# 回数制限。OGP画像の生成・OpenAI呼び出し（課金）・ログイン開始を、IPごとに制限する。
# カウンターはプロセス内のメモリ（Render は1インスタンス運用の前提）。
class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # ログイン開始・コールバック（Google OAuth）
  throttle("login/ip", limit: 10, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/users/auth/") || req.path == "/users/sign_in"
  end

  # OGP画像の生成（未ログインで呼べて、画像処理が重い）
  throttle("ogp/ip", limit: 20, period: 1.minute) do |req|
    req.ip if req.path == "/images/ogp.png"
  end

  # 投稿ページの表示（未ログインでも OGP を毎回生成して保存するため）
  throttle("games_start/ip", limit: 60, period: 1.minute) do |req|
    req.ip if req.get? && req.path.match?(%r{\A/games/[^/]+/start\z})
  end

  # OpenAI の呼び出し（課金）
  throttle("openai/ip/minute", limit: 5, period: 1.minute) do |req|
    req.ip if req.post? && req.path.start_with?("/openai_posts")
  end
  throttle("openai/ip/day", limit: 30, period: 1.day) do |req|
    req.ip if req.post? && req.path.start_with?("/openai_posts")
  end

  self.throttled_responder = lambda do |_request|
    [ 429, { "Content-Type" => "text/plain; charset=utf-8", "Retry-After" => "60" }, [ "アクセスが多いので、少し待ってからもう一度試してね" ] ]
  end
end
