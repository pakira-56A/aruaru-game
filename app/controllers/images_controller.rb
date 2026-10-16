class ImagesController < ApplicationController
  def ogp
    begin
      text = ogp_params[:text]
      image = OgpCreator.build(text).tempfile.open.read
      send_data image, type: "image/png", disposition: "inline"
      Rails.logger.info("ogpのイメージを出力") # 動的OGPに不具合があった時用に、loggerを残してます
    rescue StandardError => e
      Rails.logger.error("ogpメソッド実行中にエラー発生: #{e.message}")
      head :internal_server_error
    end
  end

  private

  def ogp_params
    params.permit(:text)
  end
end
