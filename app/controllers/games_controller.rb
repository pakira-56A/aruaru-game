class GamesController < ApplicationController
  def start
    @post = Post.find_by(id: params[:id])
    if @post.nil?
        handle_404
        return
    end

    Rails.logger.info("ポストID: #{@post.id} を取得")
    if @post.user.name != "OPEN_AI_ANSWER"
      ogp_image_url = generate_and_save_ogp(@post)
      set_meta_tags(og: { image: ogp_image_url }, twitter: { image: ogp_image_url })
    else
      Rails.logger.info("OGPを生成しない: AIが生成した投稿です")
    end
  end

  private

  def generate_and_save_ogp(post)
    begin
      image_data = OgpCreator.build("#{post.user.name}さんが思う\n#{post.title}")
      # Rails.logger.info("生成した動的OGP画像URL: #{post.ogp.url}")

      post.update!(ogp: image_data)
      # 動的OGPに不具合があった時用に、loggerを残してます
      Rails.logger.info("生成した動的OGP画像を保存: #{post.ogp.url}")
      post.ogp.url

    rescue StandardError => e
      Rails.logger.error("動的OGP画像の生成 または保存に失敗: #{e.message}")
      nil
    end
  end
end
