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

  describe "認可・不正値" do
    it '他人のいいねはIDを指定しても取り消せない（404扱い）' do
      others_like = create(:like)
      sign_in user

      expect {
        delete like_path(others_like), as: :turbo_stream
      }.not_to change(Like, :count)
      expect(response).to have_http_status(:not_found)
    end

    it '未ログインではいいねを取り消せない' do
      like = create(:like)

      expect { delete like_path(like) }.not_to change(Like, :count)
      expect(response).to redirect_to(root_path)
    end

    it '存在しないpost_idではいいねは作られず404扱いになる' do
      sign_in user

      expect {
        post likes_path(post_id: 999_999), as: :turbo_stream
      }.not_to change(Like, :count)
      expect(response).to have_http_status(:not_found)
    end

    it '同じ投稿に二重でいいねしても1件のまま増えない' do
      sign_in user
      post likes_path(post_id: post_record.id), as: :turbo_stream

      expect {
        post likes_path(post_id: post_record.id), as: :turbo_stream
      }.not_to change(Like, :count)
      expect(Like.where(user: user, post: post_record).count).to eq(1)
    end
  end
end
