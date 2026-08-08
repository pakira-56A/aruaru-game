require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーションチェック' do
    it '有効なファクトリはvalidになる' do
      expect(build(:user)).to be_valid
    end

    it 'nameがない場合、invalidになる' do
      expect(build(:user, name: "")).to be_invalid
    end

    it 'nameが重複している場合、invalidになる（大文字小文字を区別しない）' do
      create(:user, name: "たろう")
      expect(build(:user, name: "たろう")).to be_invalid
    end

    it 'uidが同じproviderで重複している場合、invalidになる' do
      create(:user, provider: "google_oauth2", uid: "123")
      expect(build(:user, provider: "google_oauth2", uid: "123")).to be_invalid
    end

    it 'uidが同じでもproviderが異なればvalidになる' do
      create(:user, provider: "google_oauth2", uid: "123")
      expect(build(:user, provider: "facebook", uid: "123")).to be_valid
    end
  end

  describe '.from_omniauth' do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "omniauth_uid_1",
        info: { name: "オムニ 太郎", email: "omni@example.com" }
      )
    end

    context 'provider と uid が一致する既存ユーザーがいる場合' do
      it '既存ユーザーをそのまま返す' do
        existing = create(:user, provider: "google_oauth2", uid: "omniauth_uid_1")
        expect { User.from_omniauth(auth) }.not_to change(User, :count)
        expect(User.from_omniauth(auth)).to eq(existing)
      end
    end

    context 'provider/uid では未登録だが、同じemailのユーザーがいる場合' do
      it '既存のemailユーザーを返し、新規作成はしない' do
        existing = create(:user, email: "omni@example.com", provider: "password", uid: nil)
        expect { User.from_omniauth(auth) }.not_to change(User, :count)
        expect(User.from_omniauth(auth)).to eq(existing)
      end
    end

    context '完全に新規のユーザーの場合' do
      it '新しくユーザーを作成して返す' do
        expect { User.from_omniauth(auth) }.to change(User, :count).by(1)
        user = User.from_omniauth(auth)
        expect(user.name).to eq("オムニ 太郎")
        expect(user.email).to eq("omni@example.com")
        expect(user).to be_persisted
      end
    end
  end

  describe 'いいね機能' do
    let(:user) { create(:user) }
    let(:post_record) { create(:post) }

    it '#like で投稿をいいねできる' do
      user.like(post_record)
      expect(user.like?(post_record)).to be true
      expect(user.like_posts).to include(post_record)
    end

    it '#unlike でいいねを取り消せる' do
      user.like(post_record)
      user.unlike(post_record)
      expect(user.like?(post_record)).to be false
    end

    it '#like? はいいねしていない投稿にはfalseを返す' do
      expect(user.like?(post_record)).to be false
    end
  end
end
