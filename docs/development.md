# 開発環境・コマンド

## 前提
- Rails 7.2.3.2 / Ruby 3.2.3 / PostgreSQL。**Docker Compose で動作**。
- アプリは常時起動しているコンテナ内で動く。
  - web コンテナ名: `aruaru-game-web-1`（作業ディレクトリ `/myapp`）
  - DB ホストは `db`（`config/database.yml`）。**ホスト直では DB につながらない**。
- ホストには gem や `curl` が入っていない。**コマンドは必ずコンテナ内で実行する**。

## よく使うコマンド
```bash
docker exec aruaru-game-web-1 bundle exec rspec            # テスト
docker exec aruaru-game-web-1 bundle exec rubocop          # Lint
docker exec aruaru-game-web-1 bundle exec rails <cmd>      # Rails
docker exec aruaru-game-web-1 sh -c 'cd /myapp && yarn <cmd>'   # フロントビルド等
```
- スモークテストは `wget`（`curl` は無い）でコンテナ内から `http://localhost:3000` を叩く。
- `bundle exec bundler-audit check --update` で gem 脆弱性監査。

## テスト方針（RSpec）
- モデル spec と request spec を使う（現状 system/Capybara spec は無し）。
- request spec の認証は `Devise::Test::IntegrationHelpers`（`sign_in`）。`spec/rails_helper.rb` で設定済み。
- factory:
  - `user`（name/uid は sequence。特別ユーザー用に `:open_ai_answer` trait）
  - `post` / `tag` / `like`
- **外部依存は必ずスタブする**:
  - OpenAI（`OpenaiService` / `Post.find_or_create_from_openai`）… 機能停止中だがテストは用意しスタブ。
  - OGP 生成（`OgpCreator`）… MiniMagick/ImageMagick は実行環境依存で不安定。
    request spec（特に `images_spec`）では **必ずスタブ**（実生成に頼ると CI で落ちる）。
- push 前にローカル（コンテナ）で **rspec 全緑 + rubocop no offenses** を必ず確認する。

## CI（GitHub Actions）
- push で `rspec` と `rubocop` の 2 ジョブが走る（`.github/workflows/main.yml`）。
- 追加テストは `bundle exec rspec` で自動的に拾われるのでワークフロー変更は基本不要。
- ImageMagick は ubuntu-latest に標準搭載だが、OGP はスタブ前提なので依存しない。
