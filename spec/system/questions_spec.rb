# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Questions", type: :system, js: true do
  let!(:department_of_tokyo) { create(:department, name: "理系", university: create(:university, name: "東京", category: :national_or_public, prefecture: Prefecture.find_by!(name: "東京都"))) }
  let!(:department_of_kyoto) { create(:department, name: "文系", university: create(:university, name: "京都", category: :national_or_public, prefecture: Prefecture.find_by!(name: "京都府"))) }
  let!(:department_of_nagoya) { create(:department, name: "理系", university: create(:university, name: "名古屋", category: :national_or_public, prefecture: Prefecture.find_by!(name: "愛知県"))) }

  describe "問題一覧機能" do
    context "問題検索画面にアクセスしたとき" do
      before do
        create_question(2000, "東京", "理系", 10, "I", "数と式・集合と論理", Settings.tex_test_code)
        visit questions_path
      end

      it "問題が表示されないこと" do
        expect(page).not_to have_selector(".question-card")
      end
    end
  end

  describe "問題検索・並び替え機能" do
    before do
      create_question(2020, "京都", "文系", 5, "I", "図形と計量")
      create_question(2010, "名古屋", "理系", 7, "II", "三角関数")
      create_question(2000, "東京", "理系", 10, "I", "数と式・集合と論理")
      visit questions_path
    end

    context "検索条件を指定しないとき" do
      it "問題は表示されず、検索フォームが表示されること" do
        expect(page).to have_selector(".search-form")
        expect(page).not_to have_selector(".question-search-conditions")
        expect(page).not_to have_selector(".question-index")
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
        expect(current_path).to eq questions_search_form_path
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "2000 年 〜 2010 年")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(all(".question-card")[0]).to have_content "名古屋"
        expect(all(".question-card")[1]).to have_content "東京"
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
        expect(current_path).to eq questions_search_form_path
        expect(page).to have_selector(".university-search-condition", text: "東京、名古屋")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(all(".question-card")[0]).to have_content "名古屋"
        expect(all(".question-card")[1]).to have_content "東京"
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
        expect(current_path).to eq questions_search_form_path
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "数と式・集合と論理、三角関数")
        expect(all(".question-card")[0]).to have_content "名古屋"
        expect(all(".question-card")[1]).to have_content "東京"
        expect(page).not_to have_content "京都"
      end
    end
  end
end
