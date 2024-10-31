# エラーチェックを有効にして、コマンドが失敗したらスクリプトを終了
set -o errexit
# Gemの依存関係を解決し、必要なライブラリをインストール
bundle install
# Renderのデータベースと連携用に追記
bundle exec rails db:migrate

# JavaScript依存ライブラリをインストール
yarn install
# JavaScriptやCSSをビルド
yarn build

# アセットをプリコンパイルして本番環境用に準備
bundle exec rails assets:precompile
# 掃除して不要なものだけ削除
bundle exec rails assets:clean