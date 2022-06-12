# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users", type: :system, js: true do
  describe "新規登録" do
    before do
      visit new_user_path
    end

    context "正常な値が入力される時" do
      it "ユーザーが作成されること" do
        fill_in "お名前", with: "hogehoge"
        fill_in "メールアドレス", with: "test@example.com"
        fill_in "パスワード", with: "1234abcd"
        fill_in "パスワード確認", with: "1234abcd"
        click_button "登録する"
        expect(page).to have_content "ユーザー登録が完了しました"
        expect(page).to have_content "プロフィール"
        expect(page).to have_content "hogehoge"
        expect(page).to have_content "test@example.com"
        expect(page).to have_selector "img[class='avatar']"
      end
    end

    context "名前以外の入力が適切な時" do
      before do
        fill_in "メールアドレス", with: "test@example.com"
        fill_in "パスワード", with: "1234abcd"
        fill_in "パスワード確認", with: "1234abcd"
      end

      it "名前のないユーザーは作成できないこと" do
        fill_in "お名前", with: ""
        click_button "登録する"
        expect(page).to have_content "ユーザー登録できませんでした"
        expect(page).to have_content "お名前 を入力して下さい"
      end

      it "名前が10文字より長いとき、ユーザーは作成できないこと" do
        fill_in "お名前", with: "hogehogehoge"
        click_button "登録する"
        expect(page).to have_content "ユーザー登録できませんでした"
        expect(page).to have_content "お名前 は10文字以下で入力して下さい"
      end
    end

    context "メールアドレス以外の入力が適切な時" do
      before do
        fill_in "お名前", with: "hoge"
        fill_in "パスワード", with: "1234abcd"
        fill_in "パスワード確認", with: "1234abcd"
      end

      it "メールアドレスのないとき、ユーザーは作成できないこと" do
        fill_in "メールアドレス", with: ""
        click_button "登録する"
        expect(page).to have_content "ユーザー登録できませんでした"
        expect(page).to have_content("メールアドレス は不正な値です") | have_content("メールアドレス を入力して下さい")
      end

      it "メールアドレスが不正な値であるとき、ユーザーは作成できないこと" do
        fill_in "メールアドレス", with: "hogehoge"
        click_button "登録する"
        expect(page).to have_content "ユーザー登録できませんでした"
        expect(page).to have_content("メールアドレス は不正な値です")
      end

      it "既に登録されているメールアドレスのとき、ユーザー作成できないこと" do
        create(:user, email: "test@example.com")
        fill_in "メールアドレス", with: "test@example.com"
        click_button "登録する"
        expect(page).to have_content "ユーザー登録できませんでした"
        expect(page).to have_content("メールアドレス は既に存在します")
      end
    end

    context "パスワード以外の入力が適切な時" do
      before do
        fill_in "お名前", with: "hoge"
        fill_in "メールアドレス", with: "test@example.com"
      end

      it "パスワードが入力されていないとき、ユーザーは作成できないこと" do
        fill_in "パスワード", with: nil
        fill_in "パスワード確認", with: "1234abcd"
        click_button "登録する"
        expect(page).to have_content "ユーザー登録できませんでした"
        expect(page).to \
          have_content("パスワード は8文字以上で入力して下さい") \
          | have_content("パスワード は不正な値です")
        expect(page).to have_content("パスワード確認 とパスワードの入力が一致しません")
      end

      it "パスワードが8文字より短いとき、ユーザーは作成できないこと" do
        fill_in "パスワード", with: "1234abc"
        fill_in "パスワード確認", with: "1234abc"
        click_button "登録する"
        expect(page).to have_content("パスワード は8文字以上で入力して下さい")
      end

      it "パスワードに英字のないとき、ユーザーは作成できないこと" do
        fill_in "パスワード", with: "12345678"
        fill_in "パスワード確認", with: "12345678"
        click_button "登録する"
        expect(page).to have_content("パスワード は不正な値です")
      end

      it "パスワードに数字のないとき、ユーザーは作成できないこと" do
        fill_in "パスワード", with: "ABCDabcd"
        fill_in "パスワード確認", with: "ABCDabcd"
        click_button "登録する"
        expect(page).to have_content("パスワード は不正な値です")
      end

      it "パスワード確認とパスワードが一致しないとき、ユーザーは作成できないこと" do
        fill_in "パスワード", with: "1234abcd"
        fill_in "パスワード確認", with: "abcd1234"
        click_button "登録する"
        expect(page).to have_content("パスワード確認 とパスワードの入力が一致しません")
      end
    end
  end

  describe "編集機能" do
    before do
      user = create(:user, email: "test@example.com")
      sign_in_as(user)
      visit edit_user_path(user)
    end

    context "正常な値が入力される時" do
      it "プロフィール編集できること" do
        fill_in "お名前", with: "fugafuga"
        fill_in "メールアドレス", with: "TEST@example.com"
        click_button "更新する"
        expect(page).to have_content "プロフィールを更新しました"
        expect(page).to have_content "プロフィール"
        expect(page).to have_content "fugafuga"
        expect(page).to have_content "TEST@example.com"
        expect(page).to have_selector "img[class='avatar']"
      end
    end

    context "名前以外の入力が適切な時" do
      it "名前のないとき、プロフィールは編集できないこと" do
        fill_in "お名前", with: ""
        click_button "更新する"
        expect(page).to have_content "プロフィールを更新できませんでした"
        expect(page).to have_content "お名前 を入力して下さい"
      end

      it "名前が10文字より長いとき、プロフィールは編集できないこと" do
        fill_in "お名前", with: "hogehogehoge"
        click_button "更新する"
        expect(page).to have_content "プロフィールを更新できませんでした"
        expect(page).to have_content "お名前 は10文字以下で入力して下さい"
      end
    end

    context "メールアドレス以外の入力が適切な時" do
      it "メールアドレスのないとき、プロフィールは編集できないこと" do
        fill_in "メールアドレス", with: ""
        click_button "更新する"
        expect(page).to have_content "プロフィールを更新できませんでした"
        expect(page).to have_content("メールアドレス は不正な値です") | have_content("メールアドレス を入力して下さい")
      end

      it "メールアドレスが不正な値であるとき、プロフィールは編集できないこと" do
        fill_in "メールアドレス", with: "hogehoge"
        click_button "更新する"
        expect(page).to have_content "プロフィールを更新できませんでした"
        expect(page).to have_content("メールアドレス は不正な値です")
      end

      it "既に登録されているメールアドレスのとき、プロフィールは編集できないこと" do
        create(:user, email: "TEST@example.com")
        fill_in "メールアドレス", with: "TEST@example.com"
        click_button "更新する"
        expect(page).to have_content "プロフィールを更新できませんでした"
        expect(page).to have_content("メールアドレス は既に存在します")
      end
    end

    context "プロフィール画像を選択する時" do
      it "画像ファイルをプロフィール画像に登録できること" do
        img_preview_before = find("#avatar-preview img")
        expect(img_preview_before["src"]).to include("blank-profile-picture.png")
        find("input[type='file']", visible: false).attach_file Rails.root.join("spec/files/avatar_test.png")
        img_preview_after = find("#avatar-preview img")
        expect(img_preview_after["src"]).not_to include("blank-profile-picture.png")
        click_button "更新する"
        expect(page).to have_content "プロフィールを更新しました"
        img = first("img[class='avatar']")
        expect(img["src"]).to include("avatar_test.png")
      end
    end
  end
end
