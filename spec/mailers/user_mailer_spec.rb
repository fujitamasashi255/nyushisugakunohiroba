# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let!(:user) { create(:user, name: "TEST", email: "test@example.com", password: "1234abcd", password_confirmation: "1234abcd") }
  let!(:mail) { user.deliver_reset_password_instructions! }

  it "送信先アドレスが正しいこと" do
    expect(mail.to).to eq [user.email]
  end

  # it "送信元アドレスが正しいこと" do
  #   expect(mail.from).to eq []
  # end
end
