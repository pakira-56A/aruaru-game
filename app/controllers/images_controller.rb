class ImagesController < ApplicationController
  before_action :authenticate_user!, raise: false

  def ogp
    Rails.logger.info("ogpメソッドを実行")
    begin
      text = ogp_params[:text]
      image = OgpCreator.build(text).tempfile.open.read
      send_data image, type: 'image/png', disposition: 'inline'
      Rails.logger.info("ogpのイメージをを出力")
    rescue StandardError => e
      Rails.logger.error("OGP画像生成中にエラーが発生: #{e.message}")
    end
  end

  private

  def ogp_params
    params.permit(:text)
  end
end
