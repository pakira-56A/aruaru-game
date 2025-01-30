require 'rails_helper'

RSpec.describe "Games", type: :request do
  describe "GET /games/start/:id" do
    let!(:post) { create(:post) } # FactoryBotを使ってポストを作成

    it "正しいポストデータを取得する" do
      get start_game_path(post.id)
      expect(response.status).to eq(200)
      expect(response).to be_successful  # レスポンスが成功であることを確認
      expect(response.body).to include(post.title)  # 投稿データのタイトルが含まれているか確認
    end
  end
end
