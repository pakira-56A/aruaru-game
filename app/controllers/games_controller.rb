class GamesController < ApplicationController
  before_action :authenticate_user!, only: %i[start]

  def start
    @post = Post.find(params[:id])
    Rails.logger.info("ポストID: #{@post.id} のOGP画像を生成中")
    begin
      image_data = OgpCreator.build(prepare_meta_tags(@post))
    rescue StandardError => e
      Rails.logger.error("OGP画像生成中にエラーが発生しました: #{e.message}")
      render json: { error: '内部サーバーエラー' }, status: :internal_server_error
      return
    end
    Rails.logger.info("生成した画像データ: #{image_data.inspect}")
  end

  private

  def authenticate_user!
    if request.user_agent =~ /bot|crawler|spider/i
      return
    end
    return if user_signed_in?
    # XシェアされたURLを未ログインユーザーがクリックした際、クリックしたURLを保存
    store_location_for(:user, request.original_url)
    flash[:alert] = 'ログインしてね〜！'
    redirect_to root_path
  end

  def prepare_meta_tags(post)
    user_name = post.user.name
    title = post.title
    ogp_text = "#{user_name}さんが思う\n#{title}"
    image_url = "#{request.base_url}/images/ogp.png?text=#{CGI.escape(ogp_text)}"

    Rails.logger.info("『#{request.base_url}』でOGP画像の生成「#{user_name}さんの#{title}」画像URL「#{image_url}」")
    set_meta_tags og: {
                    site_name: 'あるある神経衰弱',
                    title: post.title,
                    description: 'この界隈あるあるで遊ぼう！',
                    type: 'website',
                    url: "#{request.base_url}/games/#{post.id}/start",
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
