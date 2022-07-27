# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Answers", type: :system, js: true do
  let!(:user) { create(:user, name: "TEST", email: "test@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin) }
  let!(:department) { create(:department, name: "DEPT", university: create(:university, name: "UNIV", category: :national_or_public, prefecture: Prefecture.find_by!(name: "東京都"))) }
  let!(:question) { create(:question, :full_custom, year: 2000, department:, question_number: 5, unit_names: %w[三角関数]) }

  describe "解答新規作成機能" do
    before do
      # ログイン
      sign_in_as(user)
      visit new_question_answer_path(question)
    end

    context "新規作成画面にアクセスしたとき" do
      it "問題の大学、学部、問題番号が表示されていること" do
        expect(page).to have_selector(".title", text: "解答作成")
        expect(page).to have_selector(".question-info .year", text: "2000")
        expect(page).to have_selector(".question-info .university", text: "UNIV")
        expect(page).to have_selector(".question-info .departments", text: "DEPT5")
      end

      it "問題詳細へのリンクが表示されていること" do
        expect(page).to have_selector ".answer-links a[href='#{question_path(question)}']"
      end

      it "アイコンをクリックすると問題文が表示されること" do
        find(".answer-top-icons a[id='questionImageDropdownButton']").click
        expect(page).to have_selector "#dropdownQuestionImage img"
      end
    end

    context "すべての項目を入力せずに解答を作成するとき" do
      it "解答が作成できること" do
        click_button "解答を作成する"
        expect(page).to have_selector(".title", text: "解答")
        expect(page).to have_content "解答を作成しました"
        # 問題情報が表示されているか
        expect(page).to have_selector(".question-info .year", text: "2000")
        expect(page).to have_selector(".question-info .university", text: "UNIV")
        expect(page).to have_selector(".question-info .departments", text: "DEPT5")
        # 解答情報が表示されているか
        expect(page).to have_selector(".answer-show", text: "解答はありません")
        # リンクが表示されているか
        created_answer = Answer.order(created_at: :desc).first
        expect(page).to have_selector(".answer-links a[href='#{edit_answer_path(created_answer)}']")
        expect(page).to have_selector(".answer-links a[href='#{answer_path(created_answer)}'][data-method='delete']")
        expect(page).to have_selector(".answer-links a[href='#{question_path(question)}']")
      end
    end

    context "タグだけを入力するとき" do
      it "解答が作成できること" do
        find("span[class='tagify__input']").set("テストタグ")
        find("input[value='解答を作成する']").click
        expect(page).to have_selector(".title", text: "解答")
        expect(page).to have_content "解答を作成しました"
        # 解答情報が表示されているか
        expect(page).to have_selector(".tags", text: "テストタグ")
        # 問題情報が表示されているか
        expect(page).to have_selector(".question-info .year", text: "2000")
        expect(page).to have_selector(".question-info .university", text: "UNIV")
        expect(page).to have_selector(".question-info .departments", text: "DEPT5")
        # リンクが表示されているか
        created_answer = Answer.order(created_at: :desc).first
        expect(page).to have_selector(".answer-links a[href='#{edit_answer_path(created_answer)}']")
        expect(page).to have_selector(".answer-links a[href='#{answer_path(created_answer)}'][data-method='delete']")
        expect(page).to have_selector(".answer-links a[href='#{question_path(question)}']")
      end
    end

    context "ポイントだけを入力するとき" do
      it "解答が作成できること" do
        find("trix-editor").set("テストポイント")
        find("input[value='解答を作成する']").click
        expect(page).to have_selector(".title", text: "解答")
        expect(page).to have_content "解答を作成しました"
        # 解答情報が表示されているか
        expect(page).to have_selector(".point-field", text: "テストポイント")
        # 問題情報が表示されているか
        expect(page).to have_selector(".question-info .year", text: "2000")
        expect(page).to have_selector(".question-info .university", text: "UNIV")
        expect(page).to have_selector(".question-info .departments", text: "DEPT5")
        # リンクが表示されているか
        created_answer = Answer.order(created_at: :desc).first
        expect(page).to have_selector(".answer-links a[href='#{edit_answer_path(created_answer)}']")
        expect(page).to have_selector(".answer-links a[href='#{answer_path(created_answer)}'][data-method='delete']")
        expect(page).to have_selector(".answer-links a[href='#{question_path(question)}']")
      end
    end

    context "ファイル登録だけを行うとき" do
      it "ファイル登録を行うとプレビューが表示されること" do
        find("input[id='answer-files-input']", visible: false).attach_file(
          Rails.root.join("spec/files/test.png") \
        )
        expect(page).to have_selector(".preview img")
      end

      it "ファイル登録して表示されたプレビューを、クリアボタンを押して削除できること" do
        expect(page).not_to have_selector("#delete-files-button")
        find("input[id='answer-files-input']", visible: false).attach_file(
          Rails.root.join("spec/files/test.png") \
        )
        page.accept_confirm("登録したファイルを削除しますか") do
          find("#delete-files-button").click
        end
        expect(page).not_to have_selector(".preview img")
      end

      context "ファイルを3個登録して解答作成するとき" do
        before do
          find("input[id='answer-files-input']", visible: false).attach_file(\
            [\
              Rails.root.join("spec/files/test.png"), \
              Rails.root.join("spec/files/test.jpg"), \
              Rails.root.join("spec/files/test.pdf")\
            ]
          )
          find(".files input[type='hidden']:nth-child(3)", visible: false)
          sleep(2)
        end

        it "順番を指定して解答作成できること" do
          within(".preview ") do
            find("img[src*='image/png']").find(:xpath, "./../..").find("select").select "2"
            find("img[src*='image/jpeg']").find(:xpath, "./../..").find("select").select "3"
            find("iframe[src*='application/pdf']").find(:xpath, "./../..").find("select").select "1"
          end
          find("input[value='解答を作成する']").click
          expect(page).to have_selector(".title", text: "解答")
          expect(page).to have_content "解答を作成しました"
          # 解答情報が表示されているか
          expect(page).to have_selector(".files label", text: "ファイル")
          expect(all(".carousel-item")[0]).to have_selector("iframe[src$='test.pdf']")
          expect(all(".carousel-item", visible: false)[1]).to have_selector("img[src$='test.png']", visible: false)
          expect(all(".carousel-item", visible: false)[2]).to have_selector("img[src$='test.jpg']", visible: false)
          # 問題情報が表示されているか
          expect(page).to have_selector(".question-info .year", text: "2000")
          expect(page).to have_selector(".question-info .university", text: "UNIV")
          expect(page).to have_selector(".question-info .departments", text: "DEPT5")
          # リンクが表示されているか
          created_answer = Answer.order(created_at: :desc).first
          expect(page).to have_selector(".answer-links a[href='#{edit_answer_path(created_answer)}']")
          expect(page).to have_selector(".answer-links a[href='#{answer_path(created_answer)}'][data-method='delete']")
          expect(page).to have_selector(".answer-links a[href='#{question_path(question)}']")
        end
      end

      it "ファイルを4個登録して、解答が作成できないこと" do
        find("input[id='answer-files-input']", visible: false).attach_file(\
          [\
            Rails.root.join("spec/files/test.png"), \
            Rails.root.join("spec/files/test.jpg"), \
            Rails.root.join("spec/files/test.pdf"), \
            Rails.root.join("spec/files/testcopy.png") \
          ]\
        )
        find(".files .error_message", text: "アップロードできるファイルは3つまでです")
        find("input[value='解答を作成する']").click
        expect(page).to have_selector(".title", text: "解答")
        expect(page).to have_content "解答を作成しました"
        expect(page).not_to have_selector(".files img[src$='test.png']", visible: false)
        expect(page).not_to have_selector(".files img[src$='test.jpg']", visible: false)
        expect(page).not_to have_selector(".files img[src$='test.pdf']", visible: false)
        expect(page).not_to have_selector(".files img[src$='testcopy.png']", visible: false)
      end

      it "3MB以上のファイルを登録して解答が作成できないこと" do
        find("input[id='answer-files-input']", visible: false).attach_file(\
          Rails.root.join("spec/files/over_3MB_image.png") \
        )
        find(".files .error_message", text: "アップロードできるファイルの最大サイズは3MBです")
        find("input[value='解答を作成する']").click
        expect(page).to have_selector(".title", text: "解答")
        expect(page).to have_content "解答を作成しました"
        expect(page).not_to have_selector(".files img[src$='over_3MB_image.png']")
      end
    end

    context "texの作成だけを行うとき" do
      it "クリアボタンを押すとコンパイル結果が削除され、コードがデフォルトに戻ること" do
        click_link "解答を書く"
        find("#tex-code").set(Settings.tex_test_code)
        click_button "コンパイルする"
        expect(page).to have_selector("#compile-message", text: "コンパイルに成功しました")
        expect(page).to have_selector("iframe[type='application/pdf']")
        page.accept_confirm("TeXのコード、コンパイル結果を削除しますか") do
          find("#delete-tex-button").click
        end
        expect(page).not_to have_selector("textarea[id='tex-code']", text: "テスト")
        expect(page).not_to have_selector("#compile-result iframe")
      end

      it "解答が作成できること" do
        click_link "解答を書く"
        find("#tex-code").set(Settings.tex_test_code)
        click_button "コンパイルする"
        expect(page).to have_selector("#compile-message", text: "コンパイルに成功しました")
        expect(page).to have_selector("iframe[type='application/pdf']")
        find("input[value='解答を作成する']").click
        expect(page).to have_selector(".title", text: "解答")
        expect(page).to have_content "解答を作成しました"
        # 解答情報が表示されているか
        expect(page).to have_selector(".tex iframe[type='application/pdf']")
        # 問題情報が表示されているか
        expect(page).to have_selector(".question-info .year", text: "2000")
        expect(page).to have_selector(".question-info .university", text: "UNIV")
        expect(page).to have_selector(".question-info .departments", text: "DEPT5")
        # リンクが表示されているか
        created_answer = Answer.order(created_at: :desc).first
        expect(page).to have_selector(".answer-links a[href='#{edit_answer_path(created_answer)}']")
        expect(page).to have_selector(".answer-links a[href='#{answer_path(created_answer)}'][data-method='delete']")
        expect(page).to have_selector(".answer-links a[href='#{question_path(question)}']")
      end
    end
  end

  describe "解答編集、削除機能" do
    context "編集画面にアクセスしたとき" do
      before do
        @answer = create(:answer, :attached_pdf_file, question:, user:, tag_names: "テストタグ", point: "テストポイント")
        # ログイン
        sign_in_as(user)
        visit edit_answer_path(@answer)
      end

      it "問題の情報、リンクが表示されていること" do
        expect(page).to have_selector(".title", text: "解答編集")
        expect(page).to have_selector(".question-info .year", text: "2000")
        expect(page).to have_selector(".question-info .university", text: "UNIV")
        expect(page).to have_selector(".question-info .departments", text: "DEPT5")
        # 問題詳細、解答削除リンクが表示されている
        expect(page).to have_selector(".answer-links a[href='#{question_path(question)}']")
        expect(page).to have_selector(".answer-links a[href='#{answer_path(@answer)}'][data-method='delete']")
        # アイコンをクリックすると問題文が表示される
        find(".answer-top-icons a[id='questionImageDropdownButton']").click
        expect(page).to have_selector "#dropdownQuestionImage img"
      end
    end

    context "ファイルだけを編集するとき" do
      before do
        sign_in_as(user)
        visit new_question_answer_path(question)
        find("input[id='answer-files-input']", visible: false).attach_file(\
          [\
            Rails.root.join("spec/files/test.png"), \
            Rails.root.join("spec/files/test.jpg"), \
            Rails.root.join("spec/files/test.pdf")\
          ]
        )
        find(".files input[type='hidden']:nth-child(3)", visible: false)
        sleep(2)
        within(".preview ") do
          find("img[src*='image/png']").find(:xpath, "./../..").find("select").select "2"
          find("img[src*='image/jpeg']").find(:xpath, "./../..").find("select").select "3"
          find("iframe[src*='application/pdf']").find(:xpath, "./../..").find("select").select "1"
        end
        find("input[value='解答を作成する']").click
        find_link("解答編集").click
      end

      it "クリアボタンを押すと登録されたファイルが削除されること" do
        page.accept_confirm("登録したファイルを削除しますか") do
          find("#delete-files-button").click
        end
        expect(page).not_to have_selector(".preview img")
        find("input[value='解答を更新する']").click
        expect(page).to have_selector(".title", text: "解答")
        expect(page).to have_content "解答を更新しました"
        expect(page).not_to have_selector(".files")
      end

      it "順番だけを変更できること" do
        within(".preview ") do
          find("img[src$='.png']").find(:xpath, "./../..").find("select").select "3"
          find("img[src$='.jpg']").find(:xpath, "./../..").find("select").select "1"
          find("iframe[src$='.pdf']").find(:xpath, "./../..").find("select").select "2"
        end
        find("input[value='解答を更新する']").click
        expect(page).to have_selector(".title", text: "解答")
        expect(page).to have_content "解答を更新しました"
        # ファイルの順番が変更されているか
        expect(page).to have_selector(".files label", text: "ファイル")
        expect(all(".carousel-item", visible: false)[1]).to have_selector("iframe[src$='test.pdf']", visible: false)
        expect(all(".carousel-item", visible: false)[2]).to have_selector("img[src$='test.png']", visible: false)
        expect(all(".carousel-item")[0]).to have_selector("img[src$='test.jpg']", visible: false)
      end

      it "新たにファイルを登録し直せること" do
        find("input[id='answer-files-input']", visible: false).attach_file(\
          [\
            Rails.root.join("spec/files/test.png"), \
            Rails.root.join("spec/files/test.jpg"), \
            Rails.root.join("spec/files/test.pdf")\
          ]
        )
        find(".files input[type='hidden']:nth-child(3)", visible: false)
        sleep(2)
        within(".preview ") do
          find("img[src*='image/png']").find(:xpath, "./../..").find("select").select "2"
          find("img[src*='image/jpeg']").find(:xpath, "./../..").find("select").select "3"
          find("iframe[src*='application/pdf']").find(:xpath, "./../..").find("select").select "1"
        end
        find("input[value='解答を更新する']").click
        expect(page).to have_selector(".title", text: "解答")
        expect(page).to have_content "解答を更新しました"
        # 解答情報が表示されているか
        expect(page).to have_selector(".files label", text: "ファイル")
        expect(all(".carousel-item")[0]).to have_selector("iframe[src$='test.pdf']")
        expect(all(".carousel-item", visible: false)[1]).to have_selector("img[src$='test.png']", visible: false)
        expect(all(".carousel-item", visible: false)[2]).to have_selector("img[src$='test.jpg']", visible: false)
      end
    end

    context "texを編集するとき" do
      before do
        @answer = create(:answer, :attached_pdf_file, question:, user:, tag_names: "テストタグ", point: "テストポイント")
        # ログイン
        sign_in_as(user)
        visit edit_answer_path(@answer)
      end

      it "クリアボタンを押すと作成したtexのpdfが削除されること" do
        expect(page).to have_selector("#compile-result iframe")
        page.accept_confirm("TeXのコード、コンパイル結果を削除しますか") do
          find("#delete-tex-button").click
        end
        find("input[value='解答を更新する']").click
        expect(page).to have_selector(".title", text: "解答")
        expect(page).to have_content "解答を更新しました"
        expect(page).not_to have_selector(".tex label", text: "TeX")
        expect(page).not_to have_selector(".tex iframe[type='application/pdf']")
      end
    end
  end

  describe "解答詳細機能" do
    let(:department) { create(:department, name: "理系", university: create(:university, name: "東京", category: :national_or_public, prefecture: Prefecture.find_by!(name: "東京都"))) }
    before do
      # ユーザーを作成
      @user1 = create(:user, name: "TEST1", email: "test1@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin)
      @user2 = create(:user, name: "TEST2", email: "test2@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin)
      question = create(:question, :full_custom, year: 2020, department:, question_number: 5, unit_names: %w[図形と計量])
      # user1の京都大学、名古屋大学、東京大学の解答を作成
      @answer1 = create(:answer, question:, user: @user1, tag_names: "tag1")
      @answer2 = create(:answer, question:, user: @user2, tag_names: "tag2")
    end

    context "ログインしているとき" do
      before do
        # user1が@answer2にいいね
        create(:like, user: @user1, answer: @answer2)
        # ログイン
        sign_in_as(@user1)
      end

      context "user1が、いいねしていない@answer1の詳細にアクセスしたとき" do
        before do
          visit answer_path(@answer1)
        end

        it "解答編集、削除リンクが表示されていること" do
          expect(page).to have_selector(".answer-links a[href='#{edit_answer_path(@answer1)}']")
          expect(page).to have_selector(".answer-links a[href='#{answer_path(@answer1)}'][data-method='delete']")
        end

        it "解答にいいねできること" do
          expect(page).to have_selector(".answer-links .like-icon-description", text: "いいね")
          expect(page).to have_selector(".answer-links .likes-counts", text: "0")
          find(".answer-links .like-button").click
          expect(page).to have_selector(".answer-links .unlike-button")
          expect(page).to have_selector(".answer-links .likes-counts", text: "1")
        end
      end

      context "user1が、いいねしている@answer2の詳細にアクセスしたとき" do
        before do
          visit answer_path(@answer2)
        end

        it "解答編集、削除リンクが表示されないこと" do
          expect(page).not_to have_selector(".answer-links a[href='#{edit_answer_path(@answer1)}']")
          expect(page).not_to have_selector(".answer-links a[href='#{answer_path(@answer1)}'][data-method='delete']")
        end

        it "解答のいいねを解除できること" do
          expect(page).to have_selector(".answer-links .like-icon-description", text: "いいね")
          expect(page).to have_selector(".answer-links .likes-counts", text: "1")
          find(".answer-links .unlike-button").click
          expect(page).to have_selector(".answer-links .like-button")
          expect(page).to have_selector(".answer-links .likes-counts", text: "0")
        end
      end
    end

    context "ログインしていないとき" do
      before do
        visit answer_path(@answer1)
      end

      it "いいねボタンを押すとログイン誘導のモーダルが表示されていいねできないこと" do
        find(".answer-links .like-button").click
        expect(page).to have_selector(".modal .message", text: "いいねをするにはログインが必要です。", visible: true)
      end
    end
  end

  describe "解答検索、一覧機能" do
    let(:department_tokyo) { create(:department, name: "理系", university: create(:university, name: "東京", category: :national_or_public, prefecture: Prefecture.find_by!(name: "東京都"))) }
    let(:department_kyoto) { create(:department, name: "文系", university: create(:university, name: "京都", category: :national_or_public, prefecture: Prefecture.find_by!(name: "京都府"))) }
    let(:department_nagoya) { create(:department, name: "理系", university: create(:university, name: "名古屋", category: :national_or_public, prefecture: Prefecture.find_by!(name: "愛知県"))) }
    let(:department_kyusyu) { create(:department, name: "工学部", university: create(:university, name: "九州", category: :national_or_public, prefecture: Prefecture.find_by!(name: "福岡県"))) }

    before do
      # ユーザーを作成
      user1 = create(:user, name: "TEST1", email: "test1@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin)
      user2 = create(:user, name: "TEST2", email: "test2@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin)
      # 京都大学、名古屋大学、東京大学、九州大学の問題を作成
      question_kyoto = create(:question, :full_custom, year: 2020, department: department_kyoto, question_number: 5, unit_names: %w[数と式・集合と論理])
      question_nagoya = create(:question, :full_custom, year: 2010, department: department_nagoya, question_number: 7, unit_names: %w[数と式・集合と論理 三角関数])
      question_tokyo = create(:question, :full_custom, year: 2000, department: department_tokyo, question_number: 10, unit_names: %w[数と式・集合と論理 三角関数 二次関数])
      question_kyusyu = create(:question, :full_custom, year: 1990, department: department_kyusyu, question_number: 12, unit_names: %w[二次関数 三角関数])
      # user1の京都大学、名古屋大学、東京大学の解答を作成
      @answer_kyoto1 = create(:answer, question: question_kyoto, user: user1, tag_names: "tag1", updated_at: Time.current.ago(2))
      @answer_nagoya1 = create(:answer, question: question_nagoya, user: user1, tag_names: "tag2", updated_at: Time.current.ago(1))
      @answer_tokyo1 = create(:answer, question: question_tokyo, user: user1, tag_names: "tag3", updated_at: Time.current)
      # user2の九州大学の解答を作成
      @answer_kyusyu2 = create(:answer, question: question_kyusyu, user: user2, tag_names: "tag4")
      # user1が@answer_kyoto1と@answer_nagoya1にいいね
      create(:like, user: user1, answer: @answer_kyoto1)
      create(:like, user: user1, answer: @answer_nagoya1)
      # user2が@answer_kyoto1にいいね
      create(:like, user: user2, answer: @answer_kyoto1)
      # user1でログイン
      sign_in_as(user1)
      # user1の解答一覧画面へアクセス
      visit user_answers_path(user1)
    end

    context "user1の解答一覧画面にアクセスしたとき" do
      it "user1のすべての解答が、問題の出題年が新しい順に表示されること" do
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
        expect(all(".answer-card")[0]).to have_content "京都"
        expect(all(".answer-card")[1]).to have_content "名古屋"
        expect(all(".answer-card")[2]).to have_content "東京"
      end

      it "他のユーザーの解答が表示されないこと" do
        expect(page).not_to have_selector(".answer-card", text: "九州")
      end

      it "解答にいいねできること" do
        like_button_wrapper = find("#answer_#{@answer_tokyo1.id} .like-container")
        expect(like_button_wrapper).to have_selector(".likes-counts", text: "0")
        like_button_wrapper.find(".like-button").click
        expect(like_button_wrapper).to have_selector(".unlike-button")
        expect(like_button_wrapper).to have_selector(".likes-counts", text: "1")
      end

      it "解答のいいねを解除できること" do
        unlike_button_wrapper = find("#answer_#{@answer_kyoto1.id} .like-container")
        expect(unlike_button_wrapper).to have_selector(".likes-counts", text: "2")
        unlike_button_wrapper.find(".unlike-button").click
        expect(unlike_button_wrapper).to have_selector(".like-button")
        expect(unlike_button_wrapper).to have_selector(".likes-counts", text: "1")
      end
    end

    context "条件を指定せず検索するとき" do
      before do
        within(".answers-search-form") do
          find(".search-form-icon i").click
          click_button "検索する"
        end
      end

      it "すべての解答が、出題年が新しい順に表示されること" do
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
        expect(all(".answer-card")[0]).to have_content "京都"
        expect(all(".answer-card")[1]).to have_content "名古屋"
        expect(all(".answer-card")[2]).to have_content "東京"
        # user2の解答が表示されていないことをチェック
        expect(page).not_to have_selector(".answer-card", text: "九州")
      end

      it "すべての解答を、最終更新日が新しい順に並べられること" do
        find(".sort-links .updated_at_new a").click
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
        expect(all(".answer-card")[0]).to have_content "東京"
        expect(all(".answer-card")[1]).to have_content "名古屋"
        expect(all(".answer-card")[2]).to have_content "京都"
        # user2の解答が表示されていないことをチェック
        expect(page).not_to have_selector(".answer-card", text: "九州")
      end

      it "すべての解答を、いいねが多い順に並べられること" do
        find(".sort-links .like_many a").click
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
        expect(all(".answer-card")[0]).to have_content "京都"
        expect(all(".answer-card")[1]).to have_content "名古屋"
        expect(all(".answer-card")[2]).to have_content "東京"
        # user2の解答が表示されていないことをチェック
        expect(page).not_to have_selector(".answer-card", text: "九州")
      end
    end

    context "大学名で検索するとき" do
      before do
        within(".answers-search-form") do
          find(".search-form-icon i").click
          within(".search-form-universities") { click_button }
          check "東京"
          check "名古屋"
          click_button "検索する"
        end
      end

      it "解答が、出題年が新しい順に表示されること" do
        expect(page).to have_selector(".university-search-condition", text: "東京、名古屋")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
        expect(all(".answer-card")[0]).to have_content "名古屋"
        expect(all(".answer-card")[1]).to have_content "東京"
        expect(page).not_to have_content "京都"
        # user2の解答が表示されていないことをチェック
        expect(page).not_to have_selector(".answer-card", text: "九州")
      end

      it "解答を、最終更新日が新しい順に並べられること" do
        find(".sort-links .updated_at_new a").click
        expect(page).to have_selector(".university-search-condition", text: "東京、名古屋")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
        expect(all(".answer-card")[0]).to have_content "東京"
        expect(all(".answer-card")[1]).to have_content "名古屋"
        expect(page).not_to have_content "京都"
        # user2の解答が表示されていないことをチェック
        expect(page).not_to have_selector(".answer-card", text: "九州")
      end

      it "すべての解答を、いいねが多い順に並べられること" do
        find(".sort-links .like_many a").click
        expect(page).to have_selector(".university-search-condition", text: "東京、名古屋")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
        expect(all(".answer-card")[0]).to have_content "名古屋"
        expect(all(".answer-card")[1]).to have_content "東京"
        expect(page).not_to have_content "京都"
        # user2の解答が表示されていないことをチェック
        expect(page).not_to have_selector(".answer-card", text: "九州")
      end
    end

    context "単元で検索するとき" do
      before do
        within(".answers-search-form") do
          find(".search-form-icon i").click
          within(".search-form") do
            check "数と式・集合と論理"
            check "三角関数"
            click_button "検索する"
          end
        end
      end

      it "解答が、出題年が新しい順に表示されること" do
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "数と式・集合と論理、三角関数")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
        expect(all(".answer-card")[0]).to have_content "名古屋"
        expect(all(".answer-card")[1]).to have_content "東京"
        expect(page).not_to have_content "京都"
        # user2の解答が表示されていないことをチェック
        expect(page).not_to have_selector(".answer-card", text: "九州")
      end

      it "解答を、最終更新日が新しい順に並べられること" do
        find(".sort-links .updated_at_new a").click
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "数と式・集合と論理、三角関数")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
        expect(all(".answer-card")[0]).to have_content "東京"
        expect(all(".answer-card")[1]).to have_content "名古屋"
        expect(page).not_to have_content "京都"
        # user2の解答が表示されていないことをチェック
        expect(page).not_to have_selector(".answer-card", text: "九州")
      end

      it "すべての解答を、いいねが多い順に並べられること" do
        find(".sort-links .like_many a").click
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "数と式・集合と論理、三角関数")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
        expect(all(".answer-card")[0]).to have_content "名古屋"
        expect(all(".answer-card")[1]).to have_content "東京"
        expect(page).not_to have_content "京都"
        # user2の解答が表示されていないことをチェック
        expect(page).not_to have_selector(".answer-card", text: "九州")
      end
    end

    context "タグで検索するとき" do
      before do
        within(".answers-search-form") do
          find(".search-form-icon i").click
          within(".search-form") do
            find("span[class='tagify__input']").set("tag1, tag2")
            click_button "検索する"
          end
        end
      end

      it "解答が、出題年が新しい順に表示されること" do
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "tag1、tag2")
        expect(all(".answer-card")[0]).to have_content "京都"
        expect(all(".answer-card")[1]).to have_content "名古屋"
        expect(page).not_to have_content "東京"
        # user2の解答が表示されていないことをチェック
        expect(page).not_to have_selector(".answer-card", text: "九州")
      end

      it "解答を、最終更新日が新しい順に並べられること" do
        find(".sort-links .updated_at_new a").click
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "tag1、tag2")
        expect(all(".answer-card")[0]).to have_content "名古屋"
        expect(all(".answer-card")[1]).to have_content "京都"
        expect(page).not_to have_content "東京"
        # user2の解答が表示されていないことをチェック
        expect(page).not_to have_selector(".answer-card", text: "九州")
      end

      it "解答を、いいねが多い順に並べられること" do
        find(".sort-links .like_many a").click
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "tag1、tag2")
        expect(all(".answer-card")[0]).to have_content "京都"
        expect(all(".answer-card")[1]).to have_content "名古屋"
        expect(page).not_to have_content "東京"
        # user2の解答が表示されていないことをチェック
        expect(page).not_to have_selector(".answer-card", text: "九州")
      end
    end
  end
end
