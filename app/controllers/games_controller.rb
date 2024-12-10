class GamesController < ApplicationController

  def start
    @post = Post.find(params[:id])
    Rails.logger.info("ポストID: #{@post.id} を取得")

    # generate_and_save_ogp(@post)
    # set_meta_tags(og: { image: "#{@post.ogp.url}"}, twitter: { image: "#{@post.ogp.url}" }) if @post
    if @post
      ogp_image_url = generate_and_save_ogp(@post)
      set_meta_tags(og: { image: ogp_image_url }, twitter: { image: ogp_image_url })
    end
  end

    # ogp_url = ActionController::Base.helpers.image_url(@post.ogp.url)
    # set_meta_tags(og: { image: "#{ogp_url}"})
    # p ActionController::Base.helpers.image_url(@post.ogp.url)
    # generate_and_save_ogp(@post)

    # set_meta_tags(og: { image: "#{@post.ogp.url}"})
    # set_meta_tags(twitter: { image: "#{@post.ogp.url}"})
    # set_meta_tags(og: { image: './app/assets/images/OGP_game.png' }) #以前の記載

    # set_meta_tags(og: { image: "#{@post.ogp.url}"})
    # p @post.ogp.url
    # generate_and_save_ogp(@post)

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
      render json: { error: '内部サーバーエラー' }, status: :internal_server_error
    end
  end
end

    # begin
    #   image_data = OgpCreator.build("#{post.user.name}さんが思う\n#{post.title}")
    #   Rails.logger.info("生成した動的OGP画像URL: #{post.ogp.url}")
    # rescue StandardError => e
    #   Rails.logger.error("動的OGP画像の生成に失敗: #{e.message}")
    #   render json: { error: '内部サーバーエラー' }, status: :internal_server_error
    #   return
    # end

    # return unless post.update!(ogp: image_data) # 生成したOGP画像をポストに登録
    #   Rails.logger.info("生成した動的OGP画像を保存: #{post.ogp.url}")
    # rescue StandardError => e
    #   Rails.logger.error("生成した動的OGP画像を保存できませんでした: #{e.messages}")
    # end

