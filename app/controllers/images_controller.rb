class ImagesController < ApplicationController
  before_action :authenticate_user!, raise: false

  def ogp
    text = ogp_params[:text]
    image = OgpCreator.build(text).tempfile.open.read
    send_data image, type: 'image/png', disposition: 'inline'
    Rails.logger.info("ogpメソッドをを実行")
  end

  private

  def ogp_params
    params.permit(:text)
  end
end
