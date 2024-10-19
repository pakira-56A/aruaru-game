set -o errexit

bundle install

# 10.19.追記
yarn install
yarn build
yarn build:css_minify

# 卒制：Tailwindを導入追記
bundle exec rails assets:clobber

bundle exec rails assets:precompile

