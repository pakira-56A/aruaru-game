# CLAUDE.md（aruaru-game 固有）

このリポジトリ固有の前提だけを薄く記載する。
Git / PR / コミット / デプロイ分担・スキルなど**プロダクト横断の共通ルールは
`~/.claude/CLAUDE.md`（グローバル）**にある（全プロジェクトで自動読み込み）。

## このアプリの前提
- Rails 7.2.3.2 / Ruby 3.2.3 / PostgreSQL。**Docker Compose で動作**。
- **コマンドはコンテナ内で実行するのが基本**。
  - web コンテナ名: `aruaru-game-web-1`（作業ディレクトリ `/myapp`）、DB ホストは `db`。
  - ホストからも実行できる（gem・curl はあり、DB は 5433 で公開）。手順は
    [docs/development.md](docs/development.md#ホストから直接実行することもできる)。
    テストだけならこちらが速い。
- テストの外部依存（OpenAI・OGP 生成/MiniMagick）は**必ずスタブ**する。
- **テストは `bin/test` で流す**（成功時 1 行・失敗時は従来どおり詳細。全文は
  `tmp/test-logs/` に残る）。対話デバッグが要るときだけ `VERBOSE=1` を付ける。
- push 前に **rspec 全緑 + rubocop no offenses** を確認。

## グラウンディング資料（docs/）
作業前に該当ファイルを読み、事実・ルールを基準にする。機能を変えたら更新する。
- [docs/architecture.md](docs/architecture.md) … 全体像・技術・外部連携
- [docs/domain-models.md](docs/domain-models.md) … モデル・ビジネスルール
- [docs/endpoints.md](docs/endpoints.md) … ルート/認証/レスポンス形式
- [docs/conventions.md](docs/conventions.md) … 実装パターンと落とし穴
- [docs/development.md](docs/development.md) … 環境・コマンド・テスト・CI

## 既知の注意点
- `tags#destroy` は到達不能な死にコードだったため削除済み。
- タグ一覧は「投稿が 1 件以上あるタグのみ」表示（`Tag.with_posts` / `posted_by`）。
