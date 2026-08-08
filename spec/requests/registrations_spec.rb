require 'rails_helper'

RSpec.describe "Users::Registrations", type: :request do
  let(:user) { create(:user, name: "元の名前") }

  describe "GET /users/edit" do
    it 'ログインしていない場合は編集画面を表示しない' do
      get edit_user_registration_path
      expect(response).not_to be_successful
    end

    it 'ログイン中はプロフィール編集画面を表示する' do
      sign_in user
      get edit_user_registration_path
      expect(response).to be_successful
    end
  end

  describe "PUT /users (update)" do
    before { sign_in user }

    it '有効な名前で更新し、myindexにリダイレクトする' do
      put user_registration_path, params: { user: { name: "新しい名前" } }
      expect(response).to redirect_to(myindex_posts_path)
      expect(user.reload.name).to eq("新しい名前")
    end

    it '名前が空の場合は更新されない' do
      put user_registration_path, params: { user: { name: "" } }
      expect(user.reload.name).to eq("元の名前")
      expect(response).not_to redirect_to(myindex_posts_path)
    end
  end
end
