set -o errexit

bundle install

# 卒制：Tailwindを導入追記
bundle exec rails assets:clobber

bundle exec rails assets:precompile
