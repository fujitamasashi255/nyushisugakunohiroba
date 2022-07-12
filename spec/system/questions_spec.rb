# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Questions", type: :system, js: true do
  let!(:department_of_tokyo) { create(:department, name: "理系", university: create(:university, name: "東京", category: :national_or_public, prefecture: Prefecture.find_by!(name: "東京都"))) }
  let!(:department_of_kyoto) { create(:department, name: "文系", university: create(:university, name: "京都", category: :national_or_public, prefecture: Prefecture.find_by!(name: "京都府"))) }
  let!(:department_of_nagoya) { create(:department, name: "理系", university: create(:university, name: "名古屋", category: :national_or_public, prefecture: Prefecture.find_by!(name: "愛知県"))) }
  let!(:user) { create(:user, name: "TEST", email: "test@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin) }

  before do
    user1 = create(:user, name: "USER1", email: "test1@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin)
    user2 = create(:user, name: "USER2", email: "test2@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin)
    # 京都大学、名古屋大学、東京大学の問題
    @question_kyoto = create(:question, :full_custom, year: 2020, department: department_of_kyoto, question_number: 5, unit_names: %w[三角関数 図形と計量])
    @question_nagoya = create(:question, :full_custom, year: 2010, department: department_of_nagoya, question_number: 7, unit_names: %w[三角関数 数と式・集合と論理 図形と計量])
    @question_tokyo = create(:question, :full_custom, year: 2000, department: department_of_tokyo, question_number: 10, unit_names: %w[三角関数 数と式・集合と論理])
    # 京都大学の解答：2個、名古屋大学の解答：1個、東京大学の解答：0個
    create(:answer, question: @question_kyoto, user: user1, tag_names: "tag1", point: "ポイント1")
    create(:answer, question: @question_kyoto, user: user2, tag_names: nil, point: nil)
    create(:answer, question: @question_nagoya, user: user1, tag_names: "tag1")

    # ログイン
    sign_in_as(user)
  end

  describe "問題一覧機能" do
    context "問題検索画面にアクセスしたとき" do
      before do
        visit questions_path
      end

      it "問題が表示されていること" do
        expect(page).to have_selector(".search-form")
        expect(page).to have_selector(".question-search-conditions")
        expect(page).to have_selector("#questions-index")
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

  describe "問題詳細機能" do
    context "userが問題の解答を作成しており、他にも問題の解答を作成しているユーザーがいるとき" do
      before do
        @answer = create(:answer, question: @question_kyoto, user:, tag_names: "tag1")
        visit question_path(@question_kyoto)
      end

      it "問題の情報が表示されること" do
        expect(page).to have_selector ".question-show .year", text: "2020"
        expect(page).to have_selector ".question-show .university", text: "京都"
        expect(page).to have_selector ".question-show .department-name", text: "文系5"
        expect(page).to have_selector ".question-show .unit-name", text: "図形と計量"
        expect(page).to have_selector ".question-show .question-image img"
      end

      it "他のユーザーの解答が表示されること" do
        expect(page).to have_content "他のユーザーの解答"
        expect(page).to have_selector ".answer-card .user-name", text: "USER1"
        expect(page).to have_selector ".answer-card .tags", text: "tag1"
        expect(page).to have_selector ".answer-card .point", text: "ポイント1"
        expect(page).to have_selector ".answer-card .user-name", text: "USER2"
        expect(page).to have_selector ".answer-card .tags", text: "なし"
        expect(page).to have_selector ".answer-card .point-container", text: "なし"
      end

      it "自分の解答は表示されないこと" do
        expect(page).not_to have_selector ".answer-card .user-name", text: "TEST"
      end

      it "解答編集ページへのリンクが表示されること" do
        expect(page).to have_link "解答を編集する", href: edit_answer_path(@answer)
      end

      it "解答新規作成ページへのリンクは表示されないこと" do
        expect(page).not_to have_link "解答を作成する", href: new_question_answer_path(@question_kyoto)
      end
    end

    context "ユーザーが問題の解答を作成しておらず、問題の解答を作成している他のユーザーがいるとき" do
      before do
        visit question_path(@question_kyoto)
      end

      it "解答編集ページへのリンクが表示されないこと" do
        expect(page).not_to have_content "解答を編集する"
      end

      it "解答新規作成ページへのリンクが表示されること" do
        expect(page).to have_link "解答を作成する", href: new_question_answer_path(@question_kyoto)
      end
    end

    context "問題の解答を作成しているユーザーが1人もいないとき" do
      before do
        visit question_path(@question_tokyo)
      end

      it "他のユーザーの解答が表示されないこと" do
        expect(page).not_to have_selector(".answer-card")
        expect(page).to have_selector(".other-users-answers", text: "解答はありません")
      end
    end
  end
end
