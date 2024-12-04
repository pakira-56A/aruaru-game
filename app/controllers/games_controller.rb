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
    Rails.logger.info("#{request.user_agent}でアクセスしました")
    return
    # if request.user_agent =~ /bot|crawler|spider|Twitterbot/i
    #   return
    # end
    # return if user_signed_in?
    # # XシェアされたURLを未ログインユーザーがクリックした際、クリックしたURLを保存
    # store_location_for(:user, request.original_url)
    # flash[:alert] = 'ログインしてね〜！'
    # redirect_to root_path
  end

end
