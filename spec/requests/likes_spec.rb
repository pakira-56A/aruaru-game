require 'rails_helper'

RSpec.describe "Likes", type: :request do
  let(:user) { create(:user) }
  let(:post_record) { create(:post) }

  describe "POST /likes (create)" do
    it 'ログインしていない場合はrootにリダイレクトする' do
      post likes_path(post_id: post_record.id)
      expect(response).to redirect_to(root_path)
    end

    it 'ログイン中はいいねを作成できる' do
      sign_in user
      expect {
        post likes_path(post_id: post_record.id), as: :turbo_stream
      }.to change(Like, :count).by(1)
      expect(response).to be_successful
      expect(user.like?(post_record)).to be true
    end
  end

  describe "DELETE /likes/:id (destroy)" do
    it 'ログイン中はいいねを取り消せる' do
      sign_in user
      like = create(:like, user: user, post: post_record)
      expect {
        delete like_path(like), as: :turbo_stream
      }.to change(Like, :count).by(-1)
      expect(user.like?(post_record)).to be false
    end
  end

  describe "GET /likes (index)" do
    it 'ログインしていない場合はrootにリダイレクトする' do
      get likes_path
      expect(response).to redirect_to(root_path)
    end

    it 'ログイン中はいいねした投稿一覧を表示する' do
      sign_in user
      create(:like, user: user, post: post_record)
      get likes_path
      expect(response).to be_successful
      expect(response.body).to include(post_record.title)
    end
  end
end
