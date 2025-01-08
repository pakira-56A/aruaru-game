class GamesController < ApplicationController
  def start
    @post = Post.find(params[:id])
    Rails.logger.info("ポストID: #{@post.id} を取得")

    # AIが生成した投稿には動的OGPをを生成しない
    if @post && @post.user.name != "OPEN_AI_ANSWER"
      ogp_image_url = generate_and_save_ogp(@post)
      set_meta_tags(og: { image: ogp_image_url }, twitter: { image: ogp_image_url })
    end
  end

  private

  def generate_and_save_ogp(post)
    begin
      image_data = OgpCreator.build("#{post.user.name}さんが思う\n#{post.title}")
      Rails.logger.info("生成した動的OGP画像URL: #{post.ogp.url}")

      post.update!(ogp: image_data)
      Rails.logger.info("生成した動的OGP画像を保存: #{post.ogp.url}")
      post.ogp.url # 生成したOGP画像のURLを返す

    rescue StandardError => e
      Rails.logger.error("動的OGP画像の生成 または保存に失敗: #{e.message}")
      render json: { error: "内部サーバーエラー" }, status: :internal_server_error
    end
  end
end
