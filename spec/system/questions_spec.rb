# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Questions", type: :system, js: true do
  let!(:department_of_tokyo) { create(:department, name: "理系", university: create(:university, name: "東京", category: :national_or_public, prefecture: Prefecture.find_by!(name: "東京都"))) }
  let!(:department_of_kyoto) { create(:department, name: "文系", university: create(:university, name: "京都", category: :national_or_public, prefecture: Prefecture.find_by!(name: "京都府"))) }
  let!(:department_of_nagoya) { create(:department, name: "理系", university: create(:university, name: "名古屋", category: :national_or_public, prefecture: Prefecture.find_by!(name: "愛知県"))) }
  let!(:user) { create(:user, name: "TEST", email: "test@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin) }

  before do
    user1 = create(:user, name: "TEST1", email: "test1@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin)
    user2 = create(:user, name: "TEST2", email: "test2@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin)
    # 京都大学、名古屋大学、東京大学の問題
    @question_kyoto = create(:question, :full_custom, year: 2020, department: department_of_kyoto, question_number: 5, unit: "図形と計量")
    @question_nagoya = create(:question, :full_custom, year: 2010, department: department_of_nagoya, question_number: 7, unit: "三角関数")
    @question_tokyo = create(:question, :full_custom, year: 2000, department: department_of_tokyo, question_number: 10, unit: "数と式・集合と論理")
    # 京都大学の解答：2個、名古屋大学の解答：1個、東京大学の解答：0個
    create(:answer, question: @question_kyoto, user: user1, tag_names: "tag1")
    create(:answer, question: @question_kyoto, user: user2, tag_names: "tag2")
    create(:answer, question: @question_nagoya, user: user1, tag_names: "tag1")

    # ログイン
    sign_in_as(user)
  end

  describe "問題一覧機能" do
    context "問題検索画面にアクセスしたとき" do
      before do
        visit questions_path
      end

      it "問題が表示されないこと" do
        expect(page).to have_selector(".search-form")
        expect(page).not_to have_selector(".question-search-conditions")
        expect(page).not_to have_selector(".question-index")
      end
    end
  end

  describe "問題検索・並び替え機能" do
    before do
      visit questions_path
    end

    context "条件を指定せず検索する時" do
      before do
        within(".search-form") do
          click_button "検索する"
        end
      end

      it "すべての問題が出題年が新しい順に表示されること" do
        expect(current_path).to eq search_questions_path
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
        expect(all(".question-card")[0]).to have_content "京都"
        expect(all(".question-card")[1]).to have_content "名古屋"
        expect(all(".question-card")[2]).to have_content "東京"
      end

      it "すべての問題を、解答が多い順に並べられること" do
        find(".sort-links .answers_many a").click
        expect(current_path).to eq search_questions_path
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
        expect(all(".question-card")[0]).to have_content "京都"
        expect(all(".question-card")[1]).to have_content "名古屋"
        expect(all(".question-card")[2]).to have_content "東京"
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
        expect(current_path).to eq search_questions_path
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "2000 年 〜 2010 年")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
        expect(all(".question-card")[0]).to have_content "名古屋"
        expect(all(".question-card")[1]).to have_content "東京"
        expect(page).not_to have_content "京都"
      end

      it "問題が、解答が多い順に表示されること" do
        find(".sort-links .answers_many a").click
        expect(current_path).to eq search_questions_path
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "2000 年 〜 2010 年")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
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
        expect(current_path).to eq search_questions_path
        expect(page).to have_selector(".university-search-condition", text: "東京、名古屋")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
        expect(all(".question-card")[0]).to have_content "名古屋"
        expect(all(".question-card")[1]).to have_content "東京"
        expect(page).not_to have_content "京都"
      end

      it "問題が、解答が多い順に表示されること" do
        find(".sort-links .answers_many a").click
        expect(current_path).to eq search_questions_path
        expect(page).to have_selector(".university-search-condition", text: "東京、名古屋")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
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
        expect(current_path).to eq search_questions_path
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "数と式・集合と論理、三角関数")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
        expect(all(".question-card")[0]).to have_content "名古屋"
        expect(all(".question-card")[1]).to have_content "東京"
        expect(page).not_to have_content "京都"
      end

      it "問題が、解答が多い順に表示されること" do
        find(".sort-links .answers_many a").click
        expect(current_path).to eq search_questions_path
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "数と式・集合と論理、三角関数")
        expect(page).to have_selector(".tags-search-condition", text: "なし")
        expect(all(".question-card")[0]).to have_content "名古屋"
        expect(all(".question-card")[1]).to have_content "東京"
        expect(page).not_to have_content "京都"
      end
    end

    context "タグで検索するとき" do
      before do
        within(".search-form") do
          find("span[class='tagify__input']").set("tag1")
          click_button "検索する"
        end
      end

      it "問題が、出題年が新しい順に表示されること" do
        expect(current_path).to eq search_questions_path
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "tag1")
        expect(all(".question-card")[0]).to have_content "京都"
        expect(all(".question-card")[1]).to have_content "名古屋"
        expect(page).not_to have_content "東京"
      end

      it "問題が、解答が多い順に表示されること" do
        find(".sort-links .answers_many a").click
        expect(current_path).to eq search_questions_path
        expect(page).to have_selector(".university-search-condition", text: "なし")
        expect(page).to have_selector(".year-search-condition", text: "なし")
        expect(page).to have_selector(".unit-search-condition", text: "なし")
        expect(page).to have_selector(".tags-search-condition", text: "tag1")
        expect(all(".question-card")[0]).to have_content "京都"
        expect(all(".question-card")[1]).to have_content "名古屋"
        expect(page).not_to have_content "東京"
      end
    end
  end
end
