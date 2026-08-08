# アプリ固有の規約・落とし穴（エージェント用）

aruaru-game を触るときに従う実装パターンと、踏みやすい罠。**新機能・修正はこれに合わせる**。

## 実装パターン（踏襲する）
- **未ログイン制御**は `custom_authenticate_user!`（root へ誘導）。Devise 標準の `authenticate_user!` はレジストレーションのみ。
- **不正 URL/ID** は 404 ページにせず `handle_404`（`posts_path` へリダイレクト + フラッシュ）。遊びを継続させる意図。
- **`OPEN_AI_ANSWER` ユーザーの投稿は常に除外**する（index / search / autocomplete）。新しい一覧系を足すときも忘れない。`Post.exclude_open_ai_answer` を使う。
- **タグ一覧は「投稿のあるタグのみ」**（`Tag.with_posts` / `posted_by`）。`Tag.all` を直接一覧に出さない（みなしごタグが出る）。
- **フラッシュメッセージは日本語のカジュアル文体**（例「投稿したよ！遊んでもらおう！」「消したよ〜 また投稿してね！」）。既存トーンに合わせる。
- **Ransack は `title` のみ許可**（`Post.ransackable_attributes`）。他カラムで検索させたいなら明示追加が必要。
- **Turbo**: likes は turbo_stream で応答（`*.turbo_stream.erb`）。一覧系は html。

## 落とし穴（過去に踏んだ / 踏みやすい）
- **OGP 生成（`OgpCreator` / MiniMagick）は環境依存で不安定**。request spec では必ずスタブ。実生成に依存すると CI で `image/png` にならず落ちる（PR #434 前の images_spec）。
- **`games#start` は OGP 生成失敗を握りつぶす**（rescue して 200 を返す）。生成成否をテストで担保したいなら別途スタブで確認する。
- **`search_posts#autocomplete` は `q` 必須の実装だった**。`params[:q]` が nil だと `nil.tr` で 500。→ 文字列化 + 空なら `Post.none`（対応済み PR #434）。同種の tr/gsub を足すときは nil ガードを忘れない。
- **`posts#create`/`update` は `params[:post][:tag]` を `save_tags` に渡す**。tag パラメータが nil だと `nil.split` で落ちる。フォーム/テストで tag を渡す。
- **factory `user` の name/uid は sequence**。固定値で複数生成すると一意性で落ちる。
- **`tags#destroy` は削除済み**（到達不能な死にコードだった）。復活させない。未認証で危険。

## テスト方針（詳細は development.md）
- request spec は Devise ヘルパー（`sign_in`）。外部依存（OpenAI / OgpCreator）は必ずスタブ。
- push 前に `docker exec aruaru-game-web-1 bundle exec rspec`（全緑）+ `rubocop`（no offenses）。

## 変更時にこの docs も更新する
モデル・ルート・主要挙動を変えたら、`domain-models.md` / `endpoints.md` / 本ファイルの該当箇所を更新する。
