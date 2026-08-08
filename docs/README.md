# docs/（Claude 用グラウンディング資料）

Claude（ハル）が aruaru-game を触るときに読む参照資料。**ここの事実・ルールを作業の基準にする**。
機能・挙動を変えたら該当ファイルも更新すること。

| ファイル | 何を見るとき |
|---|---|
| [architecture.md](architecture.md) | 全体像・技術スタック・外部連携・主要機能の仕組み |
| [domain-models.md](domain-models.md) | モデルのフィールド/バリデーション/関連/スコープ/メソッド・ビジネスルール |
| [endpoints.md](endpoints.md) | ルート → コントローラ#アクション → 認証 → レスポンス形式 → 挙動（request spec の形式指定含む） |
| [conventions.md](conventions.md) | 従うべき実装パターンと、踏みやすい落とし穴 |
| [development.md](development.md) | 環境・コンテナ・コマンド・テスト方針・CI |

> プロダクト横断の Git/PR/デプロイ運用は `~/.claude/CLAUDE.md`（グローバル）を参照。
> 人間向けのサービス紹介は [../README.md](../README.md)。
