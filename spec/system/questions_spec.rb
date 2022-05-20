# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Questions", type: :system, js: true do
  let!(:department_of_tokyo) { create(:department, name: "理系", university: create(:university, name: "東京", category: :national_or_public, prefecture: Prefecture.find_by!(name: "東京都"))) }
  let!(:department_of_kyoto) { create(:department, name: "文系", university: create(:university, name: "京都", category: :national_or_public, prefecture: Prefecture.find_by!(name: "京都府"))) }
  let!(:department_of_nagoya) { create(:department, name: "理系", university: create(:university, name: "名古屋", category: :national_or_public, prefecture: Prefecture.find_by!(name: "愛知県"))) }

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
        # 学部checkboxの「理系」チェックし、その問題番号を10に設定
        check "理系"
        select 10, from: "問題番号"
      end

      it "単元を指定せず、問題文texをコンパイルせず新規作成できること" do
        click_button "問題を作成する"
        expect(page).to have_content "問題を作成しました"
        expect(page).to have_content "2000"
        expect(page).to have_content "東京"
        expect(page).to have_content "理系10"
        expect(page).not_to have_content "単元"
      end

      it "単元を指定せず、問題文texのコンパイルに失敗して新規作成できること" do
        fill_in "texコード", with: ""
        click_button "コンパイルする"
        expect(page).to have_selector("#compile-message", text: "コンパイルに失敗しました。ログが表示されます。")
        expect(page).to have_selector("#compile-result", text: "No pages of output.")
        click_button "問題を作成する"
        expect(page).to have_content "問題を作成しました"
        expect(page).to have_content "2000"
        expect(page).to have_content "東京"
        expect(page).to have_content "理系10"
        expect(page).not_to have_content "単元"
        expect(page).not_to have_selector("img")
      end

      it "単元を指定し、問題文texをコンパイルせず新規作成できること" do
        within(".subjectI") { check "数と式・集合と論理" }
        click_button "問題を作成する"
        expect(page).to have_content "問題を作成しました"
        expect(page).to have_content "2000"
        expect(page).to have_content "東京"
        expect(page).to have_content "理系10"
        expect(page).to have_content "数と式・集合と論理"
      end

      it "単元を指定せず、問題文texをコンパイルして新規作成できること" do
        fill_in "texコード", with: Settings.tex_test_code
        click_button "コンパイルする"
        expect(page).to have_selector("#compile-message", text: "コンパイルに成功しました")
        expect(page).to have_selector("embed[type='application/pdf']")
        click_button "問題を作成する"
        expect(page).to have_content "問題を作成しました"
        expect(page).to have_content "2000"
        expect(page).to have_content "東京"
        expect(page).to have_content "理系10"
        expect(page).to have_selector("img")
      end

      it "出題年、区分、問題番号の組が同じ問題が既に存在するとき新規作成できないこと" do
        # 東京大学理系10番の問題を作成
        create(:question, :has_a_department_with_question_number, department: department_of_tokyo, question_number: 10, year: 2000)
        select "2000", from: "出題年"
        within(".university-radio-buttons") { click_button }
        choose "東京"
        check "理系"
        select "10", from: "問題番号"
        click_button "問題を作成する"
        expect(page).to have_content "問題を作成できませんでした"
        expect(page).to have_content "出題年、区分、問題番号の組が同じ問題が存在します。"
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

    context "出題年、大学、学部、問題番号、単元のみが登録された問題を編集するとき" do
      before do
        create_question(2000, "東京", "理系", 10, "I", "数と式・集合と論理")
        find("a[role='button']", text: "編集").click
      end

      it "出題年、大学、区分、単元を変更できること" do
        # 出題年を2000に設定
        select 2020, from: "出題年"
        # 大学ラジオボタン「東京」をchoose
        within(".university-radio-buttons") { click_button }
        choose "京都"
        # 学部checkboxの「文系」チェックし、その問題番号を5に設定
        check "文系"
        select 5, from: "問題番号"
        # 単元の「図形と計量」をチェック
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
    end

    context "出題年、大学、学部、問題番号、単元、問題文texが登録された問題を編集するとき" do
      before do
        create_question(2000, "東京", "理系", 10, "I", "数と式・集合と論理", Settings.tex_test_code)
        find("a[role='button']", text: "編集").click
      end

      it "問題文texのコンパイルに失敗すると問題文が登録されないこと" do
        fill_in "texコード", with: ""
        click_button "コンパイルする"
        expect(page).to have_selector("#compile-message", text: "コンパイルに失敗しました。ログが表示されます。")
        expect(page).to have_selector("#compile-result", text: "No pages of output.")
        click_button "問題を変更する"
        expect(page).not_to have_selector("img")
      end
    end
  end

  describe "問題一覧機能" do
    before do
      create_question(2000, "東京", "理系", 10, "I", "数と式・集合と論理", Settings.tex_test_code)
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
      page.accept_confirm("本当に削除しますか") do
        within(".university-info") do
          click_on "削除"
        end
      end
      expect(page).not_to have_content "東京"
      expect(page).to have_content "見つかりませんでした"
    end
  end

  describe "問題検索・並び替え機能" do
    before do
      create_question(2020, "京都", "文系", 5, "I", "図形と計量")
      create_question(2010, "名古屋", "理系", 7, "II", "三角関数")
      create_question(2000, "東京", "理系", 10, "I", "数と式・集合と論理")
      visit admin_questions_path
      find('.search-form a[role="button"]').click
    end

    context "検索条件を指定しないとき" do
      it "すべての問題が、出題年が新しい順に表示されること" do
        expect(page).to have_content "検索条件：なし"
        expect(all(".question-card")[0]).to have_content "京都"
        expect(all(".question-card")[1]).to have_content "名古屋"
        expect(all(".question-card")[2]).to have_content "東京"
      end

      it "すべての問題を、作成日が新しい順に並べ替えること" do
        click_link "作成日が新しい順"
        expect(page).to have_content "検索条件：なし"
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
        expect(page).to have_content "検索条件：出題年「2000 年 〜 2010 年」"
        expect(all(".question-card")[0]).to have_content "名古屋"
        expect(all(".question-card")[1]).to have_content "東京"
        expect(page).not_to have_content "京都"
      end

      it "問題を、作成日が新しい順に並べ替えること" do
        click_link "作成日が新しい順"
        expect(page).to have_content "検索条件：出題年「2000 年 〜 2010 年」"
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
        expect(page).to have_content "検索条件：大学「東京、名古屋」"
        expect(all(".question-card")[0]).to have_content "名古屋"
        expect(all(".question-card")[1]).to have_content "東京"
        expect(page).not_to have_content "京都"
      end

      it "問題を、作成日が新しい順に並べ替えること" do
        click_link "作成日が新しい順"
        expect(page).to have_content "検索条件：大学「東京、名古屋」"
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
        expect(page).to have_content "検索条件：単元「数と式・集合と論理、三角関数」"
        expect(all(".question-card")[0]).to have_content "名古屋"
        expect(all(".question-card")[1]).to have_content "東京"
        expect(page).not_to have_content "京都"
      end

      it "問題を、作成日が新しい順に並べ替えること" do
        click_link "作成日が新しい順"
        expect(page).to have_content "検索条件：単元「数と式・集合と論理、三角関数」"
        expect(all(".question-card")[0]).to have_content "東京"
        expect(all(".question-card")[1]).to have_content "名古屋"
        expect(page).not_to have_content "京都"
      end
    end
  end
end
