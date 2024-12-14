class ImagesController < ApplicationController
  def ogp
    begin
      text = ogp_params[:text]
      image = OgpCreator.build(text).tempfile.open.read
      send_data image, type: "image/png", disposition: "inline"
      Rails.logger.info("ogpのイメージを出力")
    rescue StandardError => e
      Rails.logger.error("ogpメソッド実行中にエラー発生: #{e.message}")
    end
  end

  private

  def ogp_params
    params.permit(:text)
  end
end
