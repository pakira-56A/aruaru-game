class GamesController < ApplicationController
  before_action :authenticate_user!, only: %i[start]

  def start
    @post = Post.find(params[:id])
    Rails.logger.info("ポストID: #{@post.id} を取得")
    set_meta_tags(og: { image: './app/assets/images/OGP_game.png' })
    update_ogp_if_needed(@post)
  end

  private

  # 前回生成したOGP画像と比較し、投稿者名や投稿タイトルに変更があれば上書き
  def update_ogp_if_needed(post)
    previous_ogp = post.ogp # 前回のOGP画像の情報を取得
    if previous_ogp.nil? || post.user.name != post.previous_user_name || post.title != post.previous_title
      generate_and_save_ogp(post) # 変更があればOGPを生成・保存
    end
  end

  def generate_and_save_ogp(post)
    begin
      image_data = OgpCreator.build("#{post.user.name}さんが思う\n#{post.title}")
      Rails.logger.info("ここ#{request.base_url}』でOGP画像の生成「#{post.user.name}さんの#{post.title}」画像URL「#{post.ogp.url}」")
    rescue StandardError => e
      Rails.logger.error("動的OGP画像の生成に失敗: #{e.message}")
      render json: { error: '内部サーバーエラー' }, status: :internal_server_error
      return
    end

    return unless post.update!(ogp: image_data, previous_user_name: post.user.name, previous_title: post.title) # 生成したOGP画像をポストに登録
    Rails.logger.info("生成した動的OGP画像を保存: #{post.ogp.url}")
  end

end
