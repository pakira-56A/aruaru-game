# エンドポイント参照（エージェント用）

ルート → コントローラ#アクション → 認証 → レスポンス形式 → 挙動。
定義は `config/routes.rb` と `app/controllers/`。**request spec を書くときの形式（format）に注意**。

## 認証の前提
- `ApplicationController`: `protect_from_forgery with: :exception`、`set_search`（`@q = Post.ransack(params[:q])`）。
- `custom_authenticate_user!`: 未ログインなら root へリダイレクト（フラッシュ付き）。
- 不正 URL/ID は `handle_404` → **`posts_path` へリダイレクト + フラッシュ**（404 ページにしない）。

## 一覧
| メソッド/パス | アクション | 認証 | 形式 | 挙動メモ |
|---|---|---|---|---|
| GET `/` | `tops#toppage` | 不要 | html | `today_or_another` で AI 制限 Cookie を判定・削除 |
| GET `/policy` `/term` | `tops#policy/term` | 不要 | html | 静的 |
| GET `/posts` | `posts#index` | 不要 | html | ログイン時は自分の投稿を除外。常に `OPEN_AI_ANSWER` を除外 |
| GET `/posts/myindex` | `posts#myindex` | **要** | html | `users/posts/index` を render。自分の投稿一覧 |
| GET `/posts/new` | `posts#new` | **要** | html | |
| POST `/posts` | `posts#create` | **要** | html | 成功→`myindex` へ redirect / 失敗→`:new` を **422** で render。`params[:post][:tag]` で `save_tags` |
| GET `/posts/:id/edit` | `posts#edit` | **要** | html | 他人の投稿は `handle_404`（`find_by` + nil チェック） |
| PATCH/PUT `/posts/:id` | `posts#update` | **要** | html | `current_user.posts.find`。失敗時 **422** |
| DELETE `/posts/:id` | `posts#destroy` | **要** | html | transaction 内で削除、`status: :see_other` |
| GET `/games/:id/start` | `games#start` | 不要 | html | Post 取得。`OPEN_AI_ANSWER` 以外なら OGP 生成 |
| POST `/openai_posts/answer` | `openai_posts#answer` | 不要 | html | 空 question→root。生成成功→`start_game_path`。AI 制限 Cookie を付与 |
| GET `/tags` | `tags#index` | 不要 | html | `Tag.with_posts`。タグ無しなら投稿導線 |
| GET `/tags/myindex` | `tags#myindex` | **要** | html | `Tag.posted_by(current_user)` |
| GET `/tags/:id` | `tags#show` | 不要 | html | そのタグの投稿一覧 |
| GET `/search_posts/search` | `search_posts#search` | 不要 | **js / html** | Ransack（`title_cont`）。`format.js` が先。ブラウザ/Turbo は html で 200 |
| GET `/search_posts/autocomplete` | `search_posts#autocomplete` | 不要 | **js / json** | `q` を文字列化し空なら `Post.none`（PR #434）。JSON でタイトル配列 |
| GET `/likes` | `likes#index` | **要** | html | いいね一覧 |
| POST `/likes` | `likes#create` | **要** | **turbo_stream** | `params[:post_id]`。`create.turbo_stream.erb` |
| DELETE `/likes/:id` | `likes#destroy` | **要** | **turbo_stream** | `:id` は Like の id |
| GET `/images/ogp.png` | `images#ogp` | 不要 | **image/png** | `OgpCreator.build(text)` を `send_data` |

## Devise 関連
- `users/omniauth_callbacks#google_oauth2`: `verify_authenticity_token` を skip。`User.from_omniauth`。
- `users/registrations`: `edit`/`update` は `authenticate_user!`。`update_resource` で name 空チェック。
- ログイン後の遷移先は `after_sign_in_path_for` = `myindex_posts_path`。

## request spec での形式指定（重要）
- turbo_stream: `post likes_path(post_id: p.id), as: :turbo_stream`
- json: `get autocomplete_search_posts_path(q: "x"), as: :json`
- search は html 前提で `be_successful`（`Accept: */*` だと js 側に流れるので注意）。
