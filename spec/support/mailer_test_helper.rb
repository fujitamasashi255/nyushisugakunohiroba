# frozen_string_literal: true

module MailerTestHelper
  def scan_path(mail_body)
    regexp = URI::DEFAULT_PARSER.make_regexp(%w[http https])
    mail_body.scan(regexp)
    URI.parse(Regexp.last_match[0]).path
  end
end

RSpec.configure do |config|
  config.include MailerTestHelper
end
