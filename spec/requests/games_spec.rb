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

    it "ユーザー名とタイトルに含まれるHTMLをエスケープして表示する" do
      user = create(:user, name: "<script>alert(1)</script>")
      xss_post = create(:post, user: user, title: "<img src=x onerror=alert(2)>")

      get start_game_path(xss_post.id)

      expect(response.body).not_to include("<script>alert(1)</script>")
      expect(response.body).not_to include("<img src=x onerror=alert(2)>")
      expect(response.body).to include("&lt;script&gt;alert(1)&lt;/script&gt;さんが思う<br>")
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

  describe "OGP生成に失敗したとき" do
    let!(:post) { create(:post) }

    it '生成が例外を出しても握りつぶして200でゲーム画面を表示する' do
      allow(OgpCreator).to receive(:build).and_raise(StandardError, "minimagick failed")

      get start_game_path(post.id)

      expect(response).to be_successful
      expect(response.body).to include(post.title)
    end

    it '生成に失敗しても投稿のogpは書き換わらない' do
      allow(OgpCreator).to receive(:build).and_raise(StandardError, "minimagick failed")

      expect { get start_game_path(post.id) }.not_to change { post.reload.updated_at }
    end

    it '生成物の保存に失敗した場合も200を返す' do
      allow(OgpCreator).to receive(:build).and_return(nil)
      allow_any_instance_of(Post).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)

      get start_game_path(post.id)

      expect(response).to be_successful
    end
  end
end
