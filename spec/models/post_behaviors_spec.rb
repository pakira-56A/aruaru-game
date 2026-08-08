require 'rails_helper'

RSpec.describe Post, type: :model do
  describe '#save_tags' do
    let(:post_record) { create(:post) }

    it 'スペース区切りのタグを新規作成して紐付ける' do
      post_record.save_tags("野球 サッカー")
      expect(post_record.tags.map(&:tag_name)).to contain_exactly("野球", "サッカー")
    end

    it '句読点や読点でもタグを分割する' do
      post_record.save_tags("野球、サッカー。テニス")
      expect(post_record.tags.map(&:tag_name)).to contain_exactly("野球", "サッカー", "テニス")
    end

    it '重複したタグ名は1つにまとめる' do
      post_record.save_tags("野球 野球")
      expect(post_record.tags.map(&:tag_name)).to contain_exactly("野球")
    end

    it '既存のタグは再利用し、重複したTagレコードを作らない' do
      create(:tag, tag_name: "野球")
      expect { post_record.save_tags("野球") }.not_to change(Tag, :count)
    end

    it '更新時に外れたタグは紐付けから除外される' do
      post_record.save_tags("野球 サッカー")
      post_record.save_tags("野球")
      expect(post_record.tags.map(&:tag_name)).to contain_exactly("野球")
    end
  end

  describe '.exclude_open_ai_answer スコープ' do
    it 'OPEN_AI_ANSWERユーザーの投稿を除外する' do
      normal_post = create(:post)
      ai_user = create(:user, :open_ai_answer)
      ai_post = create(:post, user: ai_user)

      results = Post.exclude_open_ai_answer
      expect(results).to include(normal_post)
      expect(results).not_to include(ai_post)
    end
  end

  describe '.find_or_create_from_openai' do
    let(:question) { "エンジニア" }
    let(:openai_response) { "あるある1。あるある2。あるある3。あるある4。あるある5。" }

    context 'OpenAIが応答を返す場合' do
      it 'OPEN_AI_ANSWERユーザーの投稿を5つの回答付きで作成する' do
        allow(OpenaiService).to receive(:get_response).and_return(openai_response)

        post = Post.find_or_create_from_openai(question)

        expect(post).to be_persisted
        expect(post.title).to eq(question)
        expect(post.user.name).to eq("OPEN_AI_ANSWER")
        expect(post.aruaru_one).to eq("あるある1")
        expect(post.aruaru_five).to eq("あるある5")
      end
    end

    context 'OpenAIが応答を返さない場合' do
      it 'nilを返し、投稿を作成しない' do
        allow(OpenaiService).to receive(:get_response).and_return(nil)
        expect {
          expect(Post.find_or_create_from_openai(question)).to be_nil
        }.not_to change(Post, :count)
      end
    end

    context '同じお題の投稿が既に存在する場合' do
      it 'OpenAIを呼ばずに既存の投稿を返す' do
        ai_user = create(:user, :open_ai_answer)
        existing = create(:post, title: question, user: ai_user)

        expect(OpenaiService).not_to receive(:get_response)
        expect(Post.find_or_create_from_openai(question)).to eq(existing)
      end
    end
  end
end
