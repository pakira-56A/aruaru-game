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

  describe "不正値" do
    it '許可されていないransack属性で検索しても500にならず、絞り込みもされない' do
      create(:post, title: "野球あるある")
      get search_search_posts_path(q: { aruaru_one_cont: "存在しない文字列zzz" })
      expect(response.status).to be < 500
      expect(response.body).to include("野球あるある")
    end

    it '存在しないキーで検索しても500にならない' do
      get search_search_posts_path(q: { no_such_column_cont: "x" })
      expect(response.status).to be < 500
    end

    it 'autocompleteでqが配列やハッシュでも500にならない' do
      get autocomplete_search_posts_path(q: { a: "b" }), as: :json
      expect(response.status).to be < 500
    end
  end
end
