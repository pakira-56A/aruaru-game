class GamesController < ApplicationController
  before_action :authenticate_user!, only: %i[start]

  def start
    @post = Post.find(params[:id])
    Rails.logger.info("Generating OGP image for post ID: #{@post.id}")
    begin
      image_data = OgpCreator.build(prepare_meta_tags(@post))
    rescue StandardError => e
      Rails.logger.error("Error generating OGP image: #{e.message}")
      render json: { error: 'Internal Server Error' }, status: :internal_server_error
      return
    end
    Rails.logger.info("Generated image data: #{image_data.inspect}")
    save_ogp_image(@post, image_data)
  end

  private

  def save_ogp_image(post, image_data)
    if Rails.env.production? # 本番環境の場合
      Rails.logger.info("Returning OGP image data for post ID: #{post.id}")
      render json: { image_data: image_data } # 生成した画像データをそのまま返す
    else # 開発環境の場合
      File.open(Rails.public_path.join('ogp_images', "#{post.id}.png"), 'wb') do |file|
        file.write(image_data)
      end
      Rails.logger.info("Saved OGP image to public for post ID: #{post.id}")
    end
  end

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
