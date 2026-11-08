require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Myapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # 8.1 の既定値のうち、挙動が変わって影響を確かめきれていない2つは従来どおりにしておく。
    # - JSON 応答の文字をエスケープする（検索の候補が JSON で返るため、HTML として扱われる事故を防ぐ）
    # - hidden フィールドの autocomplete="off" を残す（ログイン・ログアウトのボタンで戻る操作をしたとき古い値を再送しないため）
    config.action_controller.escape_json_responses = true
    config.action_view.remove_hidden_field_autocomplete = false

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.generators.system_tests = nil
    config.generators do |g|
      g.skip_routes true
      g.helper false
      g.test_framework nil
    end

    config.time_zone = "Tokyo"
    config.i18n.default_locale = :ja

    config.autoload_paths += %W[#{config.root}/lib]
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
