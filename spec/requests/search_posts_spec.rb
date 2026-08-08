require 'rails_helper'

RSpec.describe "SearchPosts", type: :request do
  describe "GET /search_posts/search" do
    it 'ransackで投稿を検索して表示する' do
      create(:post, title: "野球あるある")
      get search_search_posts_path(q: { title_cont: "野球" })
      expect(response).to be_successful
    end
  end

  describe "GET /search_posts/autocomplete" do
    it 'クエリに一致する投稿タイトルをJSONで返す' do
      create(:post, title: "野球あるある")
      get autocomplete_search_posts_path(q: "野球"), as: :json
      expect(response).to be_successful
      expect(JSON.parse(response.body)).to include("野球あるある")
    end

    it 'OPEN_AI_ANSWERの投稿はサジェストに含めない' do
      ai_user = create(:user, :open_ai_answer)
      create(:post, title: "AI野球あるある", user: ai_user)
      get autocomplete_search_posts_path(q: "野球"), as: :json
      expect(JSON.parse(response.body)).not_to include("AI野球あるある")
    end

    it 'qが未指定でも500にならず、空のサジェストを返す' do
      create(:post, title: "野球あるある")
      get autocomplete_search_posts_path, as: :json
      expect(response).to be_successful
      expect(JSON.parse(response.body)).to eq([])
    end
  end
end
