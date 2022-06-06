# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UserSessions", type: :system, js: true do
  describe "ログイン" do
    let!(:general_user) { create(:user, name: "GENERAL", email: "general@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :general) }
    let!(:admin_user) { create(:user, name: "ADMIN", email: "admin@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin) }

    context "一般ユーザーの時" do
      before do
        visit login_path
        fill_in "メールアドレス", with: "general@example.com"
        fill_in "パスワード", with: "1234abcd"
        click_button "ログインする"
      end

      it "管理画面にアクセスできないこと" do
        visit admin_root_path
        expect(current_path).to eq root_path
        expect(page).not_to have_content "管理画面"
      end
    end

    context "管理ユーザーの時" do
      before do
        visit login_path
        fill_in "メールアドレス", with: "admin@example.com"
        fill_in "パスワード", with: "1234abcd"
        click_button "ログインする"
      end

      it "管理画面にアクセスできること" do
        visit admin_root_path
        expect(current_path).to eq admin_root_path
        expect(page).to have_content "管理画面"
      end
    end
  end
end
