require 'rails_helper'

RSpec.describe "Tags", type: :request do
  describe "GET /tags (index)" do
    it '投稿が紐づくタグを表示する' do
      tag = create(:tag, tag_name: "野球")
      create(:post, title: "野球あるある").tags << tag

      get tags_path

      expect(response).to be_successful
      expect(response.body).to include("##{tag.tag_name}")
    end

    it '投稿が1件もない（みなしご）タグは表示しない' do
      create(:tag, tag_name: "誰も使ってないタグ")

      get tags_path

      expect(response).to be_successful
      expect(response.body).not_to include("#誰も使ってないタグ")
    end

    it '表示できるタグが1つもない場合は投稿を促す導線を表示する' do
      get tags_path

      expect(response).to be_successful
      expect(response.body).to include(new_post_path)
    end
  end

  describe "GET /tags/myindex" do
    let(:user) { create(:user) }

    it 'ログインしていない場合はrootにリダイレクトする' do
      get myindex_tags_path
      expect(response).to redirect_to(root_path)
    end

    it '自分が投稿したタグだけを表示し、他人のタグは表示しない' do
      my_tag = create(:tag, tag_name: "自分のタグ")
      create(:post, title: "自分の投稿", user: user).tags << my_tag

      others_tag = create(:tag, tag_name: "他人のタグ")
      create(:post, title: "他人の投稿").tags << others_tag

      sign_in user
      get myindex_tags_path

      expect(response).to be_successful
      expect(response.body).to include("##{my_tag.tag_name}")
      expect(response.body).not_to include("##{others_tag.tag_name}")
    end

    it '自分のタグが1つもない場合は投稿を促す導線を表示する' do
      sign_in user
      get myindex_tags_path
      expect(response.body).to include(new_post_path)
    end
  end

  describe "GET /tags/:id (show)" do
    it 'タグに紐づく投稿を表示する' do
      tag = create(:tag)
      post_record = create(:post, title: "タグ付き投稿")
      post_record.tags << tag

      get tag_path(tag)

      expect(response).to be_successful
      expect(response.body).to include(post_record.title)
    end
  end
end
