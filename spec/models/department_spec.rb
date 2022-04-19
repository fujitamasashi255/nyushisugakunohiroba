# frozen_string_literal: true

# == Schema Information
#
# Table name: departments
#
#  id            :bigint           not null, primary key
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  university_id :bigint
#
# Indexes
#
#  index_departments_on_university_id  (university_id)
#
# Foreign Keys
#
#  fk_rails_...  (university_id => universities.id)
#
require "rails_helper"

RSpec.describe Department, type: :model do
  describe "バリデーション" do
    it "名前のない区分は作成できないこと" do
      department_without_name = build(:department, name: "")
      expect(department_without_name).to be_invalid
      expect(department_without_name.errors[:name]).to eq ["を入力して下さい"]
    end

    it "名前のある区分は作成できること" do
      department_with_name = build(:department, name: "test")
      expect(department_with_name).to be_valid
    end

    it "同じ大学に属する同名の区分は作成できないこと" do
      university = create(:university)
      university.departments << create(:department, name: "test")
      department_with_same_name = build(:department, name: "test")
      university.departments << department_with_same_name
      expect(department_with_same_name).to be_invalid
      expect(department_with_same_name.errors[:base]).to eq ["同じ名前の区分を登録することはできません"]
    end

    it "異なる大学に属する同名の区分は作成できること" do
      university_a = create(:university, name: "test")
      university_b = create(:university, name: "TEST")
      department = create(:department, name: "test", university: university_a)
      department_with_same_name = build(:department, name: department.name, university: university_b)
      expect(department_with_same_name).to be_valid
    end
  end
end
