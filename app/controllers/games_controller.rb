class GamesController < ApplicationController


  def start
    @post = Post.find(params[:id])
    Rails.logger.info("ポストID: #{@post.id} を取得")
    # set_meta_tags(og: { image: "#{@post.ogp.url}"})
    # set_meta_tags(twitter: { image: "#{@post.ogp.url}"})
    set_meta_tags(og: { image: './app/assets/images/OGP_game.png' })
    generate_and_save_ogp(@post)
  end

  private

  def generate_and_save_ogp(post)
    begin
      image_data = OgpCreator.build("#{post.user.name}さんが思う\n#{post.title}")
      Rails.logger.info("生成した動的OGP画像URL: #{post.ogp.url}")
    rescue StandardError => e
      Rails.logger.error("動的OGP画像の生成に失敗: #{e.message}")
      render json: { error: '内部サーバーエラー' }, status: :internal_server_error
      return
    end

    return unless post.update!(ogp: image_data, previous_user_name: post.user.name, previous_title: post.title) # 生成したOGP画像をポストに登録
    Rails.logger.info("生成した動的OGP画像を保存: #{post.ogp.url}")
  rescue StandardError => e
    Rails.logger.error("生成した動的OGP画像を保存できませんでした: #{e.messages}")
  end

end
