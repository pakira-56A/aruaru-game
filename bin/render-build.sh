set -o errexit

rm ../app/assets/builds/*

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean