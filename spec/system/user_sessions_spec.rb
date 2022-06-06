# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UserSessions", type: :system, js: true do
  describe "ログイン" do
    let!(:user) { create(:user, name: "TEST", email: "test@example.com", password: "1234abcd", password_confirmation: "1234abcd") }

    context "ログインしていない時" do
      before do
        visit login_path
      end

      it "登録されたメールアドレスとパスワードを入力するとログインできること" do
        fill_in "メールアドレス", with: "test@example.com"
        fill_in "パスワード", with: "1234abcd"
        click_button "ログインする"
        expect(page).to have_content "ログインしました"
        expect(page).to have_selector("#sidebar", text: "TEST", visible: false)
      end

      it "登録していないメールアドレスを入力してもログインできないこと" do
        fill_in "メールアドレス", with: "TEST@example.com"
        fill_in "パスワード", with: "1234abcd"
        click_button "ログインする"
        expect(page).to have_content "ログインできませんでした"
      end

      it "登録していないパスワードを入力してもログインできないこと" do
        fill_in "メールアドレス", with: "test@example.com"
        fill_in "パスワード", with: "1234ABCD"
        click_button "ログインする"
        expect(page).to have_content "ログインできませんでした"
      end

      it "プロフィールページにアクセスできないこと" do
        visit user_path(user)
        expect(page).to have_content "ログインして下さい"
        expect(current_path).to eq root_path
      end
    end

    context "ログインしている時" do
      before do
        sign_in_as(user)
      end

      it "ログアウトできること" do
        find("#sidebar").click_on("ログアウト")
        expect(page).to have_content "ログアウトしました"
        expect(page).to have_content "アカウント"
        expect(current_path).to eq root_path
      end

      it "ログイン画面にアクセスできないこと" do
        visit login_path
        expect(page).to have_content "既にログインしています"
        expect(current_path).to eq root_path
      end

      it "ユーザー新規登録画面にアクセスできないこと" do
        visit new_user_path
        expect(page).to have_content "既にログインしています"
        expect(current_path).to eq root_path
      end

      it "退会できること" do
        visit edit_user_path(user)
        accept_alert { click_link "退会する" }
        expect(page).to have_content "退会が完了しました"
        expect(current_path).to eq root_path
        expect(User.exists?(user.id)).to be_falsy
      end
    end
  end
end
