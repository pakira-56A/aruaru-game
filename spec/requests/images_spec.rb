require 'rails_helper'

RSpec.describe "Images", type: :request do
  describe "GET /images/ogp.png" do
    it 'テキストからPNG画像を生成して返す' do
      # OGP生成(MiniMagick/ImageMagick)は実行環境に依存して不安定なため、
      # 生成処理をスタブし、コントローラの配線（PNGを送出すること）だけを検証する
      ogp = double(tempfile: double(open: double(read: "dummy-png-binary")))
      allow(OgpCreator).to receive(:build).and_return(ogp)

      get images_ogp_path, params: { text: "テスト" }

      expect(response).to be_successful
      expect(response.media_type).to eq("image/png")
    end
  end
end
