# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Comments", type: :system, js: true do
  let!(:user) { create(:user, name: "USER", email: "test@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin) }
  let!(:department) { create(:department, name: "DEPT", university: create(:university, name: "UNIV", category: :national_or_public, prefecture: Prefecture.find_by!(name: "東京都"))) }
  let!(:question) { create(:question, :full_custom, year: 2000, department:, question_number: 5, unit_names: %w[三角関数]) }
  let!(:answer) { create(:answer, question:, user:) }

  describe "解答詳細ページでのコメント機能" do
    before do
      # ユーザーを作成
      @user1 = create(:user, name: "TEST1", email: "test1@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin)
      @user2 = create(:user, name: "TEST2", email: "test2@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin)
      # user1がanswerにコメント
      @comment = create(:comment, commentable: answer, user: @user1, body_text: "コメントテスト")
    end

    context "コメント作成者のuser1がログインしているとき" do
      before do
        # ログイン
        sign_in_as(@user1)
        # 解答詳細にアクセス
        visit answer_path(answer)
      end

      it "解答詳細画面にコメントが表示されること" do
        expect(page).to have_selector("#comments-container", text: "1件のコメント")
        expect(page).to have_selector(".comment-body", text: "コメントテスト")
        expect(all(".comment-container .user-name")[0]).to have_content "TEST1"
      end

      it "コメントを新規作成できること" do
        find("a[href='#commentField']").click
        find("#comment-form trix-editor").set("新しいコメント")
        find("#comment-form input[type='submit']").click
        expect(page).to have_content "新しいコメント"
        expect(page.all(".comment-container").count).to eq 2
        expect(first(".comment-body")).to have_content "新しいコメント"
        expect(first(".comment-container .user-name")).to have_content "TEST1"
      end

      it "コメントを編集できること" do
        find("#comment-#{@comment.id} .comment-links a[href='#{edit_comment_path(@comment)}']").click
        find("#comment-#{@comment.id} trix-editor").set("新しいコメント")
        find("#comment-#{@comment.id} .form-buttons").click_on "コメントを更新する"
        expect(page.all(".comment-container").count).to eq 1
        expect(first(".comment-body")).to have_content "新しいコメント"
        expect(first(".comment-container .user-name")).to have_content "TEST1"
      end

      it "コメントを削除できること" do
        page.accept_confirm("コメントを削除しますか") do
          find("#comment-#{@comment.id} .comment-links a[href='#{comment_path(@comment)}'][data-method='delete']").click
        end
        expect(page).not_to have_content "コメントテスト"
        expect(page.all(".comment-container").count).to eq 0
      end
    end

    context "コメント作成者でないuser2がログインしているとき" do
      before do
        # ログイン
        sign_in_as(@user2)
        # 解答詳細にアクセス
        visit answer_path(answer)
      end

      it "解答詳細画面にコメントが表示されること" do
        expect(page).to have_selector("#comments-container", text: "1件のコメント")
        expect(page).to have_selector(".comment-body", text: "コメントテスト")
        expect(all(".comment-container .user-name")[0]).to have_content "TEST1"
      end

      it "コメントを新規作成できること" do
        find("a[href='#commentField']").click
        find("#comment-form trix-editor").set("新しいコメント")
        find("#comment-form input[type='submit']").click
        expect(page).to have_content "新しいコメント"
        expect(page.all(".comment-container").count).to eq 2
        expect(first(".comment-body")).to have_content "新しいコメント"
        expect(first(".comment-container .user-name")).to have_content "TEST2"
      end

      it "コメント編集ボタンが表示されていないこと" do
        expect(page).not_to have_selector("#comment-#{@comment.id} .comment-links a[href='#{edit_comment_path(@comment)}']")
      end

      it "コメント削除ボタンが表示されていないこと" do
        expect(page).not_to have_selector("#comment-#{@comment.id} .comment-links a[href='#{comment_path(@comment)}'][data-method='delete']")
      end
    end

    context "ログインしていないとき" do
      before do
        visit answer_path(answer)
      end

      it "解答詳細画面にコメントが表示されること" do
        expect(page).to have_selector("#comments-container", text: "1件のコメント")
        expect(page).to have_selector(".comment-body", text: "コメントテスト")
        expect(all(".comment-container .user-name")[0]).to have_content "TEST1"
      end

      it "コメント新規作成フォームが表示されていないこと" do
        expect(page).not_to have_selector("a[href='#commentField']")
        expect(page).not_to have_selector("#comment-form trix-editor", visible: false)
        expect(page).not_to have_selector("#comment-form input[type='submit']", visible: false)
      end

      it "コメント編集ボタンが表示されていないこと" do
        expect(page).not_to have_selector("#comment-#{@comment.id} .comment-links a[href='#{edit_comment_path(@comment)}']")
      end

      it "コメント削除ボタンが表示されていないこと" do
        expect(page).not_to have_selector("#comment-#{@comment.id} .comment-links a[href='#{comment_path(@comment)}'][data-method='delete']")
      end
    end
  end
end
