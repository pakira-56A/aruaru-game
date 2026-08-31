# 開発環境・コマンド

## 前提
- Rails 7.2.3.2 / Ruby 3.2.3 / PostgreSQL。**Docker Compose で動作**。
- アプリは常時起動しているコンテナ内で動く。
  - web コンテナ名: `aruaru-game-web-1`（作業ディレクトリ `/myapp`）
  - DB ホストは `db`（`config/database.yml`）。**ホスト直では DB につながらない**。
- ホストには gem や `curl` が入っていない。**コマンドは必ずコンテナ内で実行する**。

## よく使うコマンド
```bash
docker exec aruaru-game-web-1 bin/test                     # テスト（推奨。出力を最小化）
docker exec aruaru-game-web-1 bundle exec rspec            # テスト（全文が出る）
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

### `bin/test`（出力を最小化するラッパー）
`bundle exec rspec` をそのまま包んだもの。**成功時は結果を 1 行だけ返し、失敗時は
これまでどおり失敗した example の詳細と再現コマンドを出す**（実測 169 行 → 1 行）。

出力は成否にかかわらず毎回 `tmp/test-logs/`（`.gitignore` 対象）に全文が残るので、
画面から消えるだけで失われない。パスは実行のたびに最後の行に出る。

```bash
bin/test                    # 全部
bin/test spec/models        # 一部だけ
bin/test --seed 1234        # rspec の引数はそのまま渡せる
VERBOSE=1 bin/test          # 成功時も全文（デバッガを仕掛けたときはこちら）
```

- 狙いは **AI コーディングエージェントのコンテキスト（トークン）の節約**。
  エージェントが打ったコマンドの出力は全文が会話履歴に入るため、
  読む値打ちの無い成功時ログが本数に比例して積み上がる。
- `binding.pry` / `debugger` を仕掛けたまま流すと入力待ちがログ側に隠れて
  画面が固まったように見える。そのときは `VERBOSE=1` を使う。
- CI は従来どおり `bundle exec rspec` を直接呼ぶ（ワークフローは変更していない）。

## CI（GitHub Actions）
- push で `rspec` と `rubocop` の 2 ジョブが走る（`.github/workflows/main.yml`）。
- 追加テストは `bundle exec rspec` で自動的に拾われるのでワークフロー変更は基本不要。
- ImageMagick は ubuntu-latest に標準搭載だが、OGP はスタブ前提なので依存しない。
