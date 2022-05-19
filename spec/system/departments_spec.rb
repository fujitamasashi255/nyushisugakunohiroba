# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Departments", type: :system, js: true do
  describe "区分新規作成機能" do
    before do
      visit new_admin_university_path
    end

    context "大学名が入力されていないとき" do
      it "区分が作成されないこと" do
        fill_in "区分名", with: "理系"
        click_button "大学・区分を作成する"
        expect(page).to have_content "大学・区分を作成できませんでした"
        expect(page).to have_selector ".invalid-feedback", text: "大学名 を入力して下さい"
        expect(page).to have_field "区分名", with: "理系"
      end
    end

    context "大学名が入力されているとき" do
      before do
        fill_in "大学名", with: "東京"
      end

      it "名前のない区分は作成できないこと" do
        fill_in "区分名", with: ""
        click_button "大学・区分を作成する"
        expect(page).to have_content "大学・区分を作成しました"
        expect(page).to have_selector ".university-name", text: "東京"
        expect(page).not_to have_selector ".department-name"
      end

      it "1つの区分が作成できること" do
        fill_in "区分名", with: "理系"
        click_button "大学・区分を作成する"
        expect(page).to have_content "大学・区分を作成しました"
        expect(page).to have_selector ".university-name", text: "東京"
        expect(page).to have_selector ".department-name", text: "理系"
      end

      it "異なる名前の区分を2つ作成できること" do
        fill_in "区分名", with: "理系"
        click_on "追加"
        within all(".nested-fields").last do
          fill_in "区分名", with: "文系"
        end
        expect(all(".nested-fields").count).to eq 2
        click_button "大学・区分を作成する"
        expect(page).to have_content "大学・区分を作成しました"
        expect(page).to have_selector ".university-name", text: "東京"
        expect(all(".department-name").count).to eq 2
        expect(page).to have_selector ".department-name", text: "理系"
        expect(page).to have_selector ".department-name", text: "文系"
      end

      it "同名の区分は作成できないこと" do
        fill_in "区分名", with: "理系"
        click_on "追加"
        within all(".nested-fields").last do
          fill_in "区分名", with: "理系"
        end
        expect(all(".nested-fields").count).to eq 2
        click_button "大学・区分を作成する"
        expect(page).to have_content "大学・区分を作成できませんでした"
        expect(page).to have_content "同じ名前の区分を登録することはできません"
        expect(page).to have_field "大学名", with: "東京"
        expect(page).to have_field "区分名", with: "理系"
      end
    end
  end

  describe "区分編集機能" do
    let(:university_has_one_department) { create(:university, :has_one_department, name: "東京", department_name: "理系") }

    before do
      visit edit_admin_university_path(university_has_one_department)
    end

    it "新しい区分を追加できること" do
      click_on "追加"
      within all(".nested-fields").last do
        fill_in "区分名", with: "文系"
      end
      expect(all(".nested-fields").count).to eq 2
      click_button "大学・区分を変更する"
      expect(page).to have_content "大学・区分を変更しました"
      expect(page).to have_selector ".university-name", text: "東京"
      expect(all(".department-name").count).to eq 2
      expect(page).to have_selector ".department-name", text: "理系"
      expect(page).to have_selector ".department-name", text: "文系"
    end

    it "区分を削除できること" do
      click_on "削除"
      expect(all(".nested-fields").count).to eq 0
      click_button "大学・区分を変更する"
      expect(page).to have_content "大学・区分を変更しました"
      expect(page).to have_selector ".university-name", text: "東京"
      expect(page).not_to have_selector ".department-name"
    end

    it "同じ名前の区分を追加できないこと" do
      click_on "追加"
      within all(".nested-fields").last do
        fill_in "区分名", with: "理系"
      end
      expect(all(".nested-fields").count).to eq 2
      click_button "大学・区分を変更する"
      expect(page).to have_content "大学・区分を変更できませんでした"
      expect(page).to have_content "同じ名前の区分を登録することはできません"
      expect(page).to have_field "大学名", with: "東京"
      expect(page).to have_field "区分名", with: "理系"
    end
  end
end
