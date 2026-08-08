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
end
