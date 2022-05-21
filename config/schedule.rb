# frozen_string_literal: true

# Rails.rootを使用するために必要
require File.expand_path("#{File.dirname(__FILE__)}/environment")
# cronを実行する環境変数
rails_env = ENV["RAILS_ENV"] || :development
# cronを実行する環境変数をセット
set :environment, rails_env
# cronのログの吐き出し場所
set :output, Rails.root.join("log/cron.log").to_s
# rakeコマンド実行時に$HOME/.rbenv/binをサーチパスへ追加
job_type :rake, "export PATH=\"$HOME/.rbenv/bin:$PATH\"; eval \"$(rbenv init -)\";cd :path && :environment_variable=:environment bundle exec rake :task --silent :output"

every 12.hours do
  rake "rails_latex:clean_rails_latex_dir"
end
