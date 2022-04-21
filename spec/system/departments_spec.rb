# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Departments", type: :system do
  describe "区分新規作成機能" do
    before do
      visit new_admin_university_path
    end

    context "大学名が入力されていないとき" do
      it "区分が作成されないこと" do
        fill_in "区分名", with: "department_name"
        click_button "大学・区分を作成する"
        expect(page).to have_content "大学・区分を作成できませんでした"
        expect(page).to have_selector ".invalid-feedback", text: "大学名 を入力して下さい"
        expect(page).to have_field "区分名", with: "department_name"
      end
    end

    context "大学名が入力されているとき" do
      before do
        fill_in "大学名", with: "university_name"
      end

      it "名前のない区分は作成できないこと" do
        fill_in "区分名", with: ""
        click_button "大学・区分を作成する"
        expect(page).to have_content "大学・区分を作成しました"
        expect(page).to have_selector ".university-name", text: "university_name"
        expect(page).not_to have_selector ".department-name"
      end

      it "1つの区分が作成できること" do
        fill_in "区分名", with: "department_name"
        click_button "大学・区分を作成する"
        expect(page).to have_content "大学・区分を作成しました"
        expect(page).to have_selector ".university-name", text: "university_name"
        expect(page).to have_selector ".department-name", text: "department_name"
      end

      it "異なる名前の区分を2つ作成できること" do
        fill_in "区分名", with: "department_name"
        click_on "追加"
        within all(".nested-fields").last do
          fill_in "区分名", with: "another_department_name"
        end
        expect(all(".nested-fields").count).to eq 2
        click_button "大学・区分を作成する"
        expect(page).to have_content "大学・区分を作成しました"
        expect(page).to have_selector ".university-name", text: "university_name"
        expect(all(".department-name").count).to eq 2
        expect(page).to have_selector ".department-name", text: "department_name"
        expect(page).to have_selector ".department-name", text: "another_department_name"
      end

      it "同名の区分は作成できないこと" do
        fill_in "区分名", with: "department_name"
        click_on "追加"
        within all(".nested-fields").last do
          fill_in "区分名", with: "department_name"
        end
        expect(all(".nested-fields").count).to eq 2
        click_button "大学・区分を作成する"
        expect(page).to have_content "大学・区分を作成できませんでした"
        expect(page).to have_content "同じ名前の区分を登録することはできません"
        expect(page).to have_field "大学名", with: "university_name"
        expect(page).to have_field "区分名", with: "department_name"
      end
    end
  end

  describe "区分編集機能" do
    let(:university_has_one_department) { create(:university, :has_one_department, name: "university_name", department_name: "department_name") }

    before do
      visit edit_admin_university_path(university_has_one_department)
    end

    it "新しい区分を追加できること" do
      click_on "追加"
      within all(".nested-fields").last do
        fill_in "区分名", with: "another_department_name"
      end
      expect(all(".nested-fields").count).to eq 2
      click_button "大学・区分を変更する"
      expect(page).to have_content "大学・区分を変更しました"
      expect(page).to have_selector ".university-name", text: "university_name"
      expect(all(".department-name").count).to eq 2
      expect(page).to have_selector ".department-name", text: "department_name"
      expect(page).to have_selector ".department-name", text: "another_department_name"
    end

    it "区分を削除できること" do
      click_on "削除"
      expect(all(".nested-fields").count).to eq 0
      click_button "大学・区分を変更する"
      expect(page).to have_content "大学・区分を変更しました"
      expect(page).to have_selector ".university-name", text: "university_name"
      expect(page).not_to have_selector ".department-name"
    end

    it "同じ名前の区分を追加できないこと" do
      click_on "追加"
      within all(".nested-fields").last do
        fill_in "区分名", with: "department_name"
      end
      expect(all(".nested-fields").count).to eq 2
      click_button "大学・区分を変更する"
      expect(page).to have_content "大学・区分を変更できませんでした"
      expect(page).to have_content "同じ名前の区分を登録することはできません"
      expect(page).to have_field "大学名", with: "university_name"
      expect(page).to have_field "区分名", with: "department_name"
    end
  end

  describe "区分一覧機能" do
    let(:university_has_departments) { create(:university, :has_departments, name: "university_name", department_counts: 5) }

    before do
      university_has_departments
      visit admin_universities_path
    end

    it "区分一覧が表示されること" do
      expect(all(".department-name").count).to eq 5
      university_has_departments.departments.each do |department|
        expect(page).to have_selector ".department-name", text: department.name
      end
    end
  end
end
