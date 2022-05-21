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
    it "大学に属さない区分は作成できないこと" do
      department = build(:department, university: nil)
      expect(department).to be_invalid
      expect(department.errors[:university]).to eq ["を指定して下さい"]
    end

    it "名前のない区分は作成できないこと" do
      department = build(:department, name: "")
      expect(department).to be_invalid
      expect(department.errors[:name]).to eq ["を入力して下さい"]
    end

    it "名前のある区分は作成できること" do
      department = build(:department, name: "name")
      expect(department).to be_valid
    end

    it "同じ大学に属する同名の区分は作成できないこと" do
      university = create(:university)
      university.departments << create(:department, university:, name: "name")
      department_with_same_name = build(:department, university:, name: "name")
      university.departments << department_with_same_name
      expect(university).to be_invalid
      expect(university.errors[:base]).to eq ["同じ名前の区分を登録することはできません"]
    end

    it "異なる大学に属する同名の区分は作成できること" do
      university_a = create(:university, name: "university_a_name")
      university_b = create(:university, name: "university_b_name")
      department = create(:department, name: "department_name", university: university_a)
      department_with_same_name = build(:department, name: department.name, university: university_b)
      expect(department_with_same_name).to be_valid
    end

    it "question_idとdepartment_idの組は一意であること" do
      question = build(:question, :has_same_departments)
      expect(question).to be_invalid
      expect(question.errors[:base]).to eq ["同一学部に同じ問題を2回以上登録できません"]
    end
  end

  describe "コールバック" do
    describe "destroy_association_question" do
      it "questionが1つのdepartmentに関連している場合、そのdepartmentを削除すると、questionも削除されること" do
        question = create(:question, :has_a_department_with_question_number)
        question.departments[0].destroy
        expect(Question.exists?(question.id)).to be_falsy
      end

      it "questionが複数のdepartmentに関連している場合、そのうちの1つを削除しても、questionは削除されないこと" do
        university = create(:university)
        department1 = create(:department, university:)
        department2 = create(:department, university:)
        question = create(:question, :has_two_departments_with_question_number, department1:, department2:)
        question.departments[0].destroy
        expect(question.departments.count).to eq 1
        expect(Question.exists?(question.id)).to be_truthy
      end
    end
  end
end
