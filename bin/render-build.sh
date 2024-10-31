# エラーチェックを有効にして、コマンドが失敗したらスクリプトを終了
set -o errexit
# Gemの依存関係を解決し、必要なライブラリをインストール
bundle install
# Renderのデータベースと連携用に追記
bundle exec rails db:migrate

# 既存のアセットを完全に削除して再生成
bundle exec rails assets:clobber

# JavaScript依存ライブラリをインストール
yarn install
# JavaScriptやCSSをビルド
yarn build
# CSSを圧縮して最適化
yarn build:css_minify
# アセットをプリコンパイルして本番環境用に準備
bundle exec rails assets:precompile