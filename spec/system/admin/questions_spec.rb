# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Questions", type: :system, js: true do
  let!(:user) { create(:user, name: "TEST", email: "test@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin) }
  let!(:department_of_tokyo) { create(:department, name: "理系", university: create(:university, name: "東京", category: :national_or_public, prefecture: Prefecture.find_by!(name: "東京都"))) }
  let!(:department_of_kyoto) { create(:department, name: "文系", university: create(:university, name: "京都", category: :national_or_public, prefecture: Prefecture.find_by!(name: "京都府"))) }
  let!(:department_of_nagoya) { create(:department, name: "理系", university: create(:university, name: "名古屋", category: :national_or_public, prefecture: Prefecture.find_by!(name: "愛知県"))) }

  before do
    sign_in_as(user)
  end

  describe "問題新規作成機能" do
    before do
      visit new_admin_question_path
    end

    context "出題年、大学、学部、問題番号が入力されているとき" do
      let(:unit) { Unit.find_by(name: "数と式・集合と論理") }

      before do
        # 出題年を2000に設定
        select 2000, from: "出題年"
        # 大学ラジオボタン「東京」をchoose
        within(".university-radio-buttons") { click_button }
        choose "東京"
        within(".university-radio-buttons") { click_button }
        # 学部checkboxの「理系」チェックし、その問題番号を10に設定
        check "理系"
        select 10, from: "問題番号"
      end

      it "問題文texをコンパイルせず新規作成できないこと" do
        click_button "問題を作成する"
        expect(page).to have_content "問題を作成できませんでした"
        expect(page).to have_content "問題文 を作成して下さい"
      end

      it "単元を指定せず新規作成できること" do
        find("#tex-code").set(Settings.tex_test_code)
        click_button "コンパイルする"
        expect(page).to have_selector("#compile-message", text: "コンパイルに成功しました")
        expect(page).to have_selector("iframe[type='application/pdf']")
        click_button "問題を作成する"
        expect(page).to have_content "問題を作成しました"
        expect(page).to have_content "2000"
        expect(page).to have_content "東京"
        expect(page).to have_content "理系10"
        expect(page).not_to have_content "単元"
        expect(page).to have_selector("img")
      end
    end

    context "区分が選択されていないとき" do
      it "問題が作成できないこと" do
        # 出題年を2000に設定
        select "2000", from: "出題年"
        # 大学ラジオボタン「東京」をchoose
        within(".university-radio-buttons") { click_button }
        choose "東京"
        click_button "問題を作成する"
        expect(page).to have_content "問題を作成できませんでした"
        expect(page).to have_content "区分を登録して下さい"
      end
    end
  end

  describe "問題編集機能" do
    before do
      visit new_admin_question_path
    end

    context "出題年、大学、学部、問題番号、単元、問題文texが登録された問題を編集するとき" do
      before do
        create_question(2000, "東京", "理系", 10, "I", "数と式・集合と論理", Settings.tex_test_code)
        find("a[role='button']", text: "編集").click
      end

      it "出題年、大学、区分、単元を変更できること" do
        select 2020, from: "出題年"
        within(".university-radio-buttons") { click_button }
        choose "京都"
        within(".university-radio-buttons") { click_button }
        check "文系"
        select 5, from: "問題番号"
        within(".subjectI") { check "図形と計量" }
        click_button "問題を変更する"
        expect(page).to have_content "問題を変更しました"
        expect(page).to have_content "2020"
        expect(page).to have_content "京都"
        expect(page).to have_content "文系5"
        expect(page).to have_content "図形と計量"
      end

      it "単元を削除できること" do
        # 単元のチェックを外す
        within(".subjectI") { uncheck "数と式・集合と論理" }
        click_button "問題を変更する"
        expect(page).to have_content "問題を変更しました"
        expect(page).to have_content "2000"
        expect(page).to have_content "東京"
        expect(page).to have_content "理系10"
        expect(page).not_to have_content "単元"
      end

      it "区分を削除して変更できないこと" do
        # 区分のチェックを外す
        uncheck "理系"
        click_button "問題を変更する"
        expect(page).to have_content "問題を変更できませんでした"
        expect(page).to have_content "区分を登録して下さい"
      end

      it "問題文texのコンパイルに失敗すると問題文が登録されないこと" do
        find("#tex-code").set("")
        click_button "コンパイルする"
        expect(page).to have_selector("#compile-message", text: "コンパイルに失敗しました。ログが表示されます。")
        expect(page).to have_selector("#compile-result", text: "No pages of output.")
        click_button "問題を変更する"
        expect(page).to have_content "問題を変更できませんでした"
        expect(page).to have_content "問題文 を作成して下さい"
      end
    end
  end

  describe "問題一覧機能" do
    before do
      create(:question, :full_custom, year: 2000, department: department_of_tokyo, question_number: 10, unit: "数と式・集合と論理")
      create(:question, :full_custom, year: 2010, department: department_of_nagoya, question_number: 7, unit: "三角関数")
      visit admin_questions_path
    end

    it "問題の出題年、大学名、区分名、問題番号、単元名、問題画像が表示されていること" do
      expect(page).to have_content "2000"
      expect(page).to have_content "東京"
      expect(page).to have_content "理系10"
      expect(page).to have_content "数と式・集合と論理"
      expect(page).to have_selector("img")
    end

    it "問題を削除できること" do
      question = Question.find_by(year: 2000)
      page.accept_confirm("削除しますか") do
        find("a[href='#{admin_question_path(question)}'] .bi-trash", visible: false).click
      end
      expect(page).to have_content "問題を削除しました"
      expect(page).not_to have_content "東京"
    end
  end

  describe "問題検索・並び替え機能" do
    before do
      create(:question, :full_custom, year: 2020, department: department_of_kyoto, question_number: 5, unit: "図形と計量")
      create(:question, :full_custom, year: 2010, department: department_of_nagoya, question_number: 7, unit: "三角関数")
      create(:question, :full_custom, year: 2000, department: department_of_tokyo, question_number: 10, unit: "数と式・集合と論理")
      visit admin_questions_path
      find(".toggle-btn").click
    end

    context "検索条件を指定しないとき" do
      it "すべての問題が、出題年が新しい順に表示されること" do
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(all(".question-card")[0]).to have_content "京都"
        expect(all(".question-card")[1]).to have_content "名古屋"
        expect(all(".question-card")[2]).to have_content "東京"
      end

      it "すべての問題を、作成日が新しい順に並べ替えること" do
        click_link "作成日が新しい順"
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(all(".question-card")[0]).to have_content "東京"
        expect(all(".question-card")[1]).to have_content "名古屋"
        expect(all(".question-card")[2]).to have_content "京都"
      end
    end

    context "出題年で検索するとき" do
      before do
        within(".search-form") do
          find("#questions_search_form_start_year").select 2000
          find("#questions_search_form_end_year").select 2010
          click_button "検索する"
        end
      end

      it "問題が、出題年が新しい順に表示されること" do
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "2000 年 〜 2010 年")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(all(".question-card")[0]).to have_content "名古屋"
        expect(all(".question-card")[1]).to have_content "東京"
        expect(page).not_to have_content "京都"
      end

      it "問題を、作成日が新しい順に並べ替えること" do
        click_link "作成日が新しい順"
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "2000 年 〜 2010 年")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(all(".question-card")[0]).to have_content "東京"
        expect(all(".question-card")[1]).to have_content "名古屋"
        expect(page).not_to have_content "京都"
      end
    end

    context "大学名で検索するとき" do
      before do
        within(".search-form") do
          within(".search-form-universities") { click_button }
          check "東京"
          check "名古屋"
          click_button "検索する"
        end
      end

      it "問題が、出題年が新しい順に表示されること" do
        expect(page).to have_selector(".university-search-condition", text: "東京、名古屋")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(all(".question-card")[0]).to have_content "名古屋"
        expect(all(".question-card")[1]).to have_content "東京"
        expect(page).not_to have_content "京都"
      end

      it "問題を、作成日が新しい順に並べ替えること" do
        click_link "作成日が新しい順"
        expect(page).to have_selector(".university-search-condition", text: "東京、名古屋")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(all(".question-card")[0]).to have_content "東京"
        expect(all(".question-card")[1]).to have_content "名古屋"
        expect(page).not_to have_content "京都"
      end
    end

    context "単元で検索するとき" do
      before do
        within(".search-form") do
          check "数と式・集合と論理"
          check "三角関数"
          click_button "検索する"
        end
      end

      it "問題が、出題年が新しい順に表示されること" do
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "数と式・集合と論理、三角関数")
        expect(all(".question-card")[0]).to have_content "名古屋"
        expect(all(".question-card")[1]).to have_content "東京"
        expect(page).not_to have_content "京都"
      end

      it "問題を、作成日が新しい順に並べ替えること" do
        click_link "作成日が新しい順"
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "数と式・集合と論理、三角関数")
        expect(all(".question-card")[0]).to have_content "東京"
        expect(all(".question-card")[1]).to have_content "名古屋"
        expect(page).not_to have_content "京都"
      end
    end
  end
end
