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

    it "存在しないIDの場合は404扱いでpostsにリダイレクトする" do
      get start_game_path(id: 999999)
      expect(response).to redirect_to(posts_path)
    end

    it "OPEN_AI_ANSWERユーザーの投稿ではOGPを生成しない" do
      ai_user = create(:user, :open_ai_answer)
      ai_post = create(:post, user: ai_user)
      expect(OgpCreator).not_to receive(:build)

      get start_game_path(ai_post.id)

      expect(response).to be_successful
    end
  end
end
