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

    it 'タグ一覧への導線を表示する' do
      get posts_path
      expect(response.body).to include(tags_path)
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

    it '自分のタグ一覧への導線を表示する' do
      sign_in user
      get myindex_posts_path
      expect(response.body).to include(myindex_tags_path)
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

  describe "認可: 他人の投稿・未ログイン" do
    let!(:others) { create(:post, title: "他人のタイトル") }

    it '未ログインでPOST /postsしても作られず、rootにリダイレクトする' do
      expect { post posts_path, params: post_params }.not_to change(Post, :count)
      expect(response).to redirect_to(root_path)
    end

    it '未ログインでPATCH /posts/:idしても更新されず、rootにリダイレクトする' do
      patch post_path(others), params: post_params(title: "更新後タイトル")
      expect(response).to redirect_to(root_path)
      expect(others.reload.title).to eq("他人のタイトル")
    end

    it 'ログイン中でも他人の投稿は更新できない（404扱いで内容は変わらない）' do
      sign_in user
      patch post_path(others), params: post_params(title: "更新後タイトル")
      expect(response).to have_http_status(:not_found)
      expect(others.reload.title).to eq("他人のタイトル")
    end

    it 'ログイン中でも他人の投稿は削除できない' do
      sign_in user
      expect { delete post_path(others) }.not_to change(Post, :count)
      expect(Post.exists?(others.id)).to be true
    end

    it '未ログインでDELETE /posts/:idしても削除されない' do
      expect { delete post_path(others) }.not_to change(Post, :count)
      expect(Post.exists?(others.id)).to be true
    end
  end

  describe "タグ空・nilの扱い" do
    before { sign_in user }

    it '作成時にtagが空文字でも投稿は作られる' do
      expect { post posts_path, params: post_params(tag: "") }.to change(user.posts, :count).by(1)
      expect(Post.last.tags).to be_empty
    end

    it '作成時にtagパラメータが無くても500にならず投稿は作られる' do
      params = post_params
      params[:post].delete(:tag)
      expect { post posts_path, params: params }.to change(user.posts, :count).by(1)
      expect(response).to redirect_to(myindex_posts_path)
    end

    it '更新時にtagが空文字なら既存タグが外れる' do
      own = create(:post, user: user)
      own.save_tags("野球")
      patch post_path(own), params: post_params(tag: "")
      expect(response).to redirect_to(myindex_posts_path)
      expect(own.reload.tags).to be_empty
    end

    it '更新時にtagパラメータが無くても500にならない' do
      own = create(:post, user: user)
      params = post_params(title: "更新")
      params[:post].delete(:tag)
      patch post_path(own), params: params
      expect(response).to redirect_to(myindex_posts_path)
    end
  end
end
