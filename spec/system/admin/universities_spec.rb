# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Universities", type: :system, js: true do
  let!(:user) { create(:user, name: "TEST", email: "test@example.com", password: "1234abcd", password_confirmation: "1234abcd", role: :admin) }

  before do
    sign_in_as(user)
  end

  describe "大学新規作成機能" do
    before do
      visit new_admin_university_path
    end

    it "名前のない大学は作成できないこと" do
      fill_in "大学名", with: ""
      click_button "大学・区分を作成する"
      expect(page).to have_content "大学・区分を作成できませんでした"
      expect(page).to have_selector ".invalid-feedback", text: "大学名 を入力して下さい"
    end

    context "同名の大学がないとき" do
      it "名前のある大学は作成できること" do
        fill_in "大学名", with: "東京"
        click_button "大学・区分を作成する"
        expect(page).to have_content "大学・区分を作成しました"
        expect(page).to have_content "東京"
      end
    end

    context "同名の大学があるとき" do
      before do
        create(:university, name: "東京")
      end

      it "同じ名前の大学は作成できないこと" do
        fill_in "大学名", with: "東京"
        click_button "大学・区分を作成する"
        expect(page).to have_content "大学・区分を作成できませんでした"
        expect(page).to have_selector ".invalid-feedback", text: "大学名 は既に存在します"
        expect(page).to have_field "大学名", with: "東京"
      end
    end
  end

  describe "大学編集機能" do
    let(:edit_university) { create(:university, name: "京都") }

    before do
      visit edit_admin_university_path(edit_university)
    end

    it "大学名を変更できること" do
      fill_in "大学名", with: "大阪"
      click_button "大学・区分を変更する"
      expect(current_path).to eq admin_university_path(edit_university)
      expect(page).to have_content "大学・区分を変更しました"
      expect(page).to have_content "大阪"
    end

    it "大学名を空欄にはできないこと" do
      fill_in "大学名", with: ""
      click_button "大学・区分を変更する"
      expect(page).to have_content "大学・区分を変更できませんでした"
      expect(page).to have_selector ".invalid-feedback", text: "大学名 を入力して下さい"
    end

    it "既に存在する大学と同じ名前には変更できないこと" do
      create(:university, name: "東京")
      fill_in "大学名", with: "東京", fill_options: { clear: :backspace }
      click_button "大学・区分を変更する"
      expect(page).to have_content "大学・区分を変更できませんでした"
      expect(page).to have_content "大学名 は既に存在します"
      expect(page).to have_field "大学名", with: "東京"
    end
  end

  describe "大学一覧機能" do
    let!(:university_tokyo) { create(:university, :has_one_department, name: "東京", department_name: "理系") }
    let!(:university_kyoto) { create(:university, :has_one_department, name: "京都", department_name: "文系") }

    before do
      visit admin_universities_path
    end

    it "大学・区分が一覧で表示されること" do
      expect(all(".university-name").count).to eq 2
      expect(page).to have_selector ".university-name", text: "東京"
      expect(page).to have_selector ".university-name", text: "京都"
      expect(all(".department-name").count).to eq 2
      expect(page).to have_selector ".department-name", text: "理系"
      expect(page).to have_selector ".department-name", text: "文系"
    end

    it "大学名で検索できること" do
      fill_in "大学名", with: "東京"
      click_button "検索"
      expect(page).to have_selector ".university-name", text: "東京"
      expect(page).not_to have_selector ".university-name", text: "京都"
    end

    it "大学を削除できること" do
      # university_tokyoを削除
      page.accept_confirm("本当に削除しますか") do
        within(".university#{university_tokyo.id}-info") do
          find(".bi-trash").click
        end
      end
      expect(page).to have_content "大学・区分を削除しました"
      expect(all(".university-name").count).to eq 1
      expect(page).to have_selector ".university-name", text: "京都"
    end
  end
end
