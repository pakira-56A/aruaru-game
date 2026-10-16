require 'rails_helper'

RSpec.describe "OpenaiPosts", type: :request do
  describe "POST /openai_posts/answer" do
    it 'お題が空の場合はrootにリダイレクトする' do
      post answer_openai_posts_path, params: { question: "" }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end

    it '投稿が生成できたらゲーム画面にリダイレクトする' do
      generated = create(:post)
      allow(Post).to receive(:find_or_create_from_openai).and_return(generated)

      post answer_openai_posts_path, params: { question: "エンジニア" }

      expect(response).to redirect_to(start_game_path(generated))
    end

    it 'AI呼び出しが上限などでnilの場合はrootにリダイレクトしアラートを出す' do
      allow(Post).to receive(:find_or_create_from_openai).and_return(nil)

      post answer_openai_posts_path, params: { question: "エンジニア" }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include("AI使いすぎ")
    end

    it '生成した投稿が保存に失敗した場合はrootにリダイレクトしアラートを出す' do
      unsaved = build(:post)
      allow(Post).to receive(:find_or_create_from_openai).and_return(unsaved)

      post answer_openai_posts_path, params: { question: "エンジニア" }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include("あるある思いつかない")
    end
  end

  describe "Cookie（cookie_count）" do
    it '生成に成功したら、今日の日付を値にしたcookie_countをhttponly・SameSite=Laxで発行する' do
      generated = create(:post)
      allow(Post).to receive(:find_or_create_from_openai).and_return(generated)

      post answer_openai_posts_path, params: { question: "エンジニア" }

      set_cookie = response.headers["Set-Cookie"].to_s
      expect(set_cookie).to include("cookie_count=#{Time.zone.today}")
      expect(set_cookie).to match(/httponly/i)
      expect(set_cookie).to match(/samesite=lax/i)
      expect(set_cookie).to match(/expires=/i)
    end

    it 'お題が空のときはcookie_countを発行しない' do
      post answer_openai_posts_path, params: { question: "" }

      expect(response.headers["Set-Cookie"].to_s).not_to include("cookie_count")
    end

    it 'cookie_count発行後にトップを開くと、今日の日付のcookie_countは削除されず保持される' do
      generated = create(:post)
      allow(Post).to receive(:find_or_create_from_openai).and_return(generated)
      post answer_openai_posts_path, params: { question: "エンジニア" }

      get root_path

      expect(cookies[:cookie_count]).to eq(Time.zone.today.to_s)
    end
  end
end
