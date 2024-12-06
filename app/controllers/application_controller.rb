class ApplicationController < ActionController::Base
  # deviseコントローラを使う前に、deviseコントローラーが真なら以下のアクションを実行する
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :prepare_meta_tags

  private

  def configure_permitted_parameters
    # 情報更新時にnameの取得を許可
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def prepare_meta_tags(post)
    user_name = post.user.name
    title = post.title
    ogp_text = "#{user_name}さんが思う\n#{title}"
    # 一旦動的OGPが生成された時刻を表示 &ts=#{ts}
    ts = Time.now.utc.strftime('%Y%m%d%H%M%S')
    image_url = "#{request.base_url}/images/ogp.png?text=#{CGI.escape(ogp_text)}&ts=#{ts}"

    Rails.logger.info("ここ#{request.base_url}』でOGP画像の生成「#{user_name}さんの#{title}」画像URL「#{image_url}」")
    set_meta_tags og: {
                    site_name: 'あるある神経衰弱',
                    title: post.title,
                    description: 'この界隈あるあるで遊ぼう！',
                    type: 'website',
                    url: request.original_url,
                    # url: "#{request.base_url}/games/#{post.id}/start",
                    image: image_url,
                    locale: 'ja-JP'
                  },
                  twitter: {
                    card: 'summary_large_image',
                    site: '@https://x.com/pakira_rrr',
                    image: image_url
                  }
    ogp_text # 生成したテキストを返す
  end
end
