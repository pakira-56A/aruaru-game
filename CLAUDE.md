# CLAUDE.md（aruaru-game 固有）

このリポジトリ固有の前提だけを薄く記載する。
Git / PR / コミット / デプロイ分担・スキルなど**プロダクト横断の共通ルールは
`~/.claude/CLAUDE.md`（グローバル）**にある（全プロジェクトで自動読み込み）。

## このアプリの前提
- Rails 7.2.3.2 / Ruby 3.2.3 / PostgreSQL。**Docker Compose で動作**。
- **コマンドは常時起動中のコンテナ内で実行**する（ホストには gem や curl が無い）。
  - web コンテナ名: `aruaru-game-web-1`（作業ディレクトリ `/myapp`）、DB ホストは `db`。
- テストの外部依存（OpenAI・OGP 生成/MiniMagick）は**必ずスタブ**する。
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
