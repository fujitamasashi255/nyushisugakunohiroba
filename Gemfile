# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem "rails", "~> 6.1.5"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use Puma as the app server
gem "puma", "~> 5.0"
# Use SCSS for stylesheets
gem "sass-rails", ">= 6"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "~> 5.0"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.7"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
gem "image_processing", "~> 1.2"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.4", require: false

# テンプレートエンジン
gem "slim-rails"

# フォーム
gem "simple_form"
gem "cocoon"

# 検索
gem "ransack"

# ページネーション
gem "pagy"

# i18n
gem "i18n-js"
gem "enum_help"

# メール
gem "net-smtp"
gem "net-imap"
gem "net-pop"

# ruby hash as a readonly datasource for an ActiveRecord-like model
gem "active_hash"

# tex
gem "rails-latex"

# image processing
gem "ruby-vips"

# 定数管理
gem "config"

# cronを設定
gem "whenever", require: false

# 認証
gem "sorcery"

# ActiveStorageのバリデーション
gem "active_storage_validations"

# タグづけ
gem "acts-as-taggable-on", "~> 9.0"

# デコレータ
gem "active_decorator"

gem "gon"

group :development, :test do
  # デバッグ
  gem "debug", ">= 1.0.0"

  # Test
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "capybara"

  # N+1問題の検出
  gem "bullet"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 4.1.0"

  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "rack-mini-profiler", "~> 2.0"
  gem "listen", "~> 3.3"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"

  # Lint
  gem "rubocop-github"
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rails_best_practices", require: false

  # エラー表示
  gem "better_errors"
  gem "binding_of_caller"

  # Lint、テスト自動化
  gem "overcommit"

  # モデルファイルにテーブル情報をコメント
  gem "annotate"

  # htmlをslimに変換
  gem "html2slim", require: false

  # メール
  gem "letter_opener_web", "~> 2.0"
end

group :test do
  # webdriver
  gem "webdrivers"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
