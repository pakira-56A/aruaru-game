# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header
#
# 外部から読み込むものの一覧（増やしたらここも足す）
# - Google Analytics（gtag.js）: www.googletagmanager.com / *.google-analytics.com / *.analytics.google.com
# - 画像: i.gyazo.com（遊び方のGIF）/ img.icons8.com（アイコン）/ S3（OGP画像）。
#   画像は読み込み元が増えやすいので https 全体を許可している
#
# インラインの <script> / <style> には nonce を付ける（content_security_policy_nonce）。
# onclick="..." や href="javascript:..." は動かなくなるので、Stimulus の data-action で書く。

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.base_uri    :self
    policy.object_src  :none
    policy.frame_ancestors :self
    policy.font_src    :self, :data
    policy.img_src     :self, :data, :https
    policy.script_src  :self,
                       "https://www.googletagmanager.com"
    policy.style_src   :self
    policy.connect_src :self,
                       "https://*.google-analytics.com",
                       "https://*.analytics.google.com",
                       "https://*.googletagmanager.com"
  end

  # nonce はセッションに1つ持たせて使い回す（Turboで画面遷移しても同じ nonce のまま使えるようにするため）。
  # セッションIDから作る既定の書き方だと、初回訪問でセッションがまだ無いときに空になる。
  config.content_security_policy_nonce_generator = ->(request) { request.session[:csp_nonce] ||= SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]

  # 違反したものは実際にブロックする（ローカルで全画面を開いて違反が出ないことを確認済み）。
  config.content_security_policy_report_only = false
end
