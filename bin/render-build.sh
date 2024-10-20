set -o errexit

bundle install


# 卒制：Tailwindを導入追記
bundle exec rails assets:clobber

# 10.19.追記（10.20.5行目から移動）
yarn install
yarn build
yarn build:css_minify

bundle exec rails assets:precompile

