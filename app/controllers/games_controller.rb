class GamesController < ApplicationController
  before_action :authenticate_user!, only: %i[start]

  def start
    @post = Post.find(params[:id])
    prepare_meta_tags(@post)
    Rails.logger.info("ポストID: #{@post.id} を取得")
    generate_and_save_ogp(@post)
  end

  private

  def generate_and_save_ogp(post)
    begin
      image_data = OgpCreator.build(prepare_meta_tags(post))
    rescue StandardError => e
      Rails.logger.error('動的OGP画像の生成に失敗')
      render json: { error: '内部サーバーエラー' }, status: :internal_server_error
      return
    end

    Rails.logger.info("生成した動的OGP画像: #{image_data.inspect}")
    return unless post.update!(ogp: image_data) # 生成したOGP画像をポストに登録

    ogp_url = post.ogp.url
    Rails.logger.info("生成した動的OGP画像を保存: #{ogp_url}")
  end

  def authenticate_user!
    Rails.logger.info("アクセスしたのは#{request.user_agent}")
    if request.user_agent =~ /bot|crawler|spider|Twitterbot/i
      return
    end
    return if user_signed_in?

    # XシェアされたURLを未ログインユーザーがクリックした際、クリックしたURLを保存
    store_location_for(:user, request.original_url)
    flash[:alert] = 'ログインしてね〜！'
    redirect_to root_path
  end

end
