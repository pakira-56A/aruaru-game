require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let(:user) { create(:user) }

  # OGP生成（MiniMagick）はテストでは不要なのでスタブする
  before { allow(OgpCreator).to receive(:build).and_return(nil) }

  # 投稿フォームの送信パラメータ。overridesで一部だけ差し替える
  def post_params(overrides = {})
    { post: { title: "新規タイトル", aruaru_one: "1", aruaru_two: "2", aruaru_three: "3",
              aruaru_four: "4", aruaru_five: "5", tag: "野球 サッカー" }.merge(overrides) }
  end

  describe "GET /posts (index)" do
    it 'ログインしていなくても閲覧でき、OPEN_AI_ANSWERの投稿は除外される' do
      visible = create(:post, title: "みんなのあるある")
      ai_user = create(:user, :open_ai_answer)
      hidden = create(:post, title: "AIのあるある", user: ai_user)

      get posts_path

      expect(response).to be_successful
      expect(response.body).to include(visible.title)
      expect(response.body).not_to include(hidden.title)
    end

    it 'ログイン中は自分の投稿を除外して表示する' do
      own = create(:post, title: "自分の投稿", user: user)
      other = create(:post, title: "他人の投稿")
      sign_in user

      get posts_path

      expect(response).to be_successful
      expect(response.body).to include(other.title)
      expect(response.body).not_to include(own.title)
    end
  end

  describe "GET /posts/myindex" do
    it 'ログインしていない場合はrootにリダイレクトする' do
      get myindex_posts_path
      expect(response).to redirect_to(root_path)
    end

    it 'ログイン中は自分の投稿一覧を表示する' do
      own = create(:post, title: "マイ投稿", user: user)
      sign_in user

      get myindex_posts_path

      expect(response).to be_successful
      expect(response.body).to include(own.title)
    end
  end

  describe "GET /posts/new" do
    it 'ログインしていない場合はrootにリダイレクトする' do
      get new_post_path
      expect(response).to redirect_to(root_path)
    end

    it 'ログイン中は投稿フォームを表示する' do
      sign_in user
      get new_post_path
      expect(response).to be_successful
    end
  end

  describe "POST /posts (create)" do
    before { sign_in user }

    it '有効なパラメータで投稿を作成し、myindexにリダイレクトする' do
      expect { post posts_path, params: post_params }.to change(user.posts, :count).by(1)
      expect(response).to redirect_to(myindex_posts_path)
    end

    it 'タグも一緒に保存される' do
      post posts_path, params: post_params
      expect(Post.last.tags.map(&:tag_name)).to contain_exactly("野球", "サッカー")
    end

    it '無効なパラメータでは作成されず、422を返す' do
      expect { post posts_path, params: post_params(title: "") }.not_to change(Post, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /posts/:id/edit" do
    before { sign_in user }

    it '自分の投稿は編集画面を表示する' do
      own = create(:post, user: user)
      get edit_post_path(own)
      expect(response).to be_successful
    end

    it '他人の投稿を編集しようとすると404扱いでpostsにリダイレクトする' do
      others = create(:post)
      get edit_post_path(others)
      expect(response).to redirect_to(posts_path)
    end
  end

  describe "PATCH /posts/:id (update)" do
    before { sign_in user }
    let(:own) { create(:post, user: user) }

    it '有効なパラメータで更新し、myindexにリダイレクトする' do
      patch post_path(own), params: post_params(title: "更新後タイトル")
      expect(response).to redirect_to(myindex_posts_path)
      expect(own.reload.title).to eq("更新後タイトル")
    end

    it '無効なパラメータでは422を返す' do
      patch post_path(own), params: post_params(title: "")
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /posts/:id (destroy)" do
    before { sign_in user }

    it '自分の投稿を削除できる' do
      own = create(:post, user: user)
      expect { delete post_path(own) }.to change(user.posts, :count).by(-1)
      expect(response).to redirect_to(myindex_posts_path)
    end
  end
end
