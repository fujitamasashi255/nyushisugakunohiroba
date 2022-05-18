# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_chrome_headless
  end
end

Capybara.configure do |config|
  config.default_max_wait_time = 5
end
