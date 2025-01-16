source "https://rubygems.org"
ruby "3.2.3"

gem "devise"
gem "omniauth"
gem "pry-byebug"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"
gem "googleauth"
gem "dotenv"

# 動的OGP用
gem "mini_magick"
gem "meta-tags", require: "meta_tags"
gem "carrierwave", "~> 3.0"
gem "fog-aws"

gem "ransack"
gem "rails-i18n"
gem "devise-i18n"
gem "devise-i18n-views"

gem "ruby-openai"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.3", ">= 7.1.3.4"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
# gem "puma", ">= 5.0"
gem "puma", ">= 6.4.3"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"
# CSSをバンドルするgem
gem "cssbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
    # RubocopのLintチェック
    gem "rubocop"
    gem "rubocop-rails"
    gem "rubocop-checkstyle_formatter"

    # Github Actions用に追加
    gem "bundler-audit"

    gem "rspec-rails"          # Rspec用に追加
    gem "factory_bot_rails"    # Rspec用に追加
    gem "rspec_junit_formatter"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  gem "rubocop-rails-omakase", require: false
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
