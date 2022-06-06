# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PasswordResets", type: :system, js: true do
  include ActiveJob::TestHelper

  describe "パスワードリセット機能" do
    let!(:user) { create(:user, name: "TEST", email: "test@example.com", password: "1234abcd", password_confirmation: "1234abcd") }

    before do
      visit new_password_reset_path

      perform_enqueued_jobs do
        fill_in "メールアドレス", with: "test@example.com"
        click_on "送信する"
      end

      mail = ActionMailer::Base.deliveries.last
      password_reset_path = scan_path(mail.body.encoded)
      visit password_reset_path
    end

    it "パスワードをリセットできること" do
      fill_in "パスワード", with: "abcd1234"
      fill_in "パスワード確認", with: "abcd1234"
      click_on "更新する"
      expect(page).to have_content "パスワードを変更しました"
    end

    it "不正な値ではパスワードをリセットできないこと" do
      fill_in "パスワード", with: "abcdABCD"
      fill_in "パスワード確認", with: "abcdABCD"
      click_on "更新する"
      expect(page).to have_content "パスワードを変更できませんでした"
      expect(page).to have_content "パスワード は不正な値です"
    end
  end
end
