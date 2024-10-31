# エラーチェックを有効にして、コマンドが失敗したらスクリプトを終了
set -o errexit
# Gemの依存関係を解決し、必要なライブラリをインストール
bundle install
# Renderのデータベースと連携用に追記
bundle exec rails db:migrate

# 古いアセットを削除し、不要なものだけ捨てる
bundle exec rails assets:clean

# JavaScript依存ライブラリをインストール
yarn install
# JavaScriptやCSSをビルド
yarn build
# CSSを圧縮して最適化
yarn build:css_minify
# アセットをプリコンパイルして本番環境用に準備
bundle exec rails assets:precompile