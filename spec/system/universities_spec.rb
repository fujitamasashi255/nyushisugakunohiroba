# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Universities", type: :system do
  describe "大学新規作成機能" do
    let(:university) { create(:university, name: "university_name") }

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
        fill_in "大学名", with: "university_name"
        click_button "大学・区分を作成する"
        expect(page).to have_content "大学・区分を作成しました"
        expect(page).to have_content "university_name"
      end
    end

    context "同名の大学があるとき" do
      it "同じ名前の大学は作成できないこと" do
        fill_in "大学名", with: university.name
        click_button "大学・区分を作成する"
        expect(page).to have_content "大学・区分を作成できませんでした"
        expect(page).to have_selector ".invalid-feedback", text: "大学名 は既に存在します"
        expect(page).to have_field "大学名", with: university.name
      end
    end
  end

  describe "大学編集機能" do
    let(:university_edit) { create(:university, name: "university_edit_name") }
    let(:university) { create(:university, name: "university_name") }

    before do
      visit edit_admin_university_path(university_edit)
    end

    it "大学名を変更できること" do
      fill_in "大学名", with: "university_edit_another_name"
      click_button "大学・区分を変更する"
      expect(current_path).to eq admin_university_path(university_edit)
      expect(page).to have_content "大学・区分を変更しました"
      expect(page).to have_content "university_edit_another_name"
    end

    it "大学名を空欄にはできないこと" do
      fill_in "大学名", with: ""
      click_button "大学・区分を変更する"
      expect(page).to have_content "大学・区分を変更できませんでした"
      expect(page).to have_selector ".invalid-feedback", text: "大学名 を入力して下さい"
    end

    it "既に存在する大学と同じ名前には変更できないこと" do
      fill_in "大学名", with: university.name, fill_options: { clear: :backspace }
      click_button "大学・区分を変更する"
      expect(page).to have_content "大学・区分を変更できませんでした"
      expect(page).to have_content "大学名 は既に存在します"
      expect(page).to have_field "大学名", with: university.name
    end
  end

  describe "大学一覧機能" do
    let(:university_list) { create_list(:university, 5) }

    before do
      university_list
      visit admin_universities_path
    end

    it "大学が一覧で表示されること" do
      expect(all(".university-name").count).to eq 5
      university_list.each do |university|
        expect(page).to have_selector ".university-name", text: university.name
      end
    end

    it "大学名で検索できること" do
      fill_in "大学名", with: university_list[0].name
      click_button "検索"
      expect(page).to have_selector ".university-name", text: university_list[0].name
    end

    it "大学を削除できること" do
      page.accept_confirm("本当に削除しますか") do
        within first("tr") do
          click_on "削除"
        end
      end
      expect(page).to have_content "大学・区分を削除しました"
      expect(all(".university-name").count).to eq 4
      University.all.each do |university|
        expect(page).to have_selector ".university-name", text: university.name
      end
    end
  end
end
