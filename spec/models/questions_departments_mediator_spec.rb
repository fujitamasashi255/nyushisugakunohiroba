# frozen_string_literal: true

# == Schema Information
#
# Table name: questions_departments_mediators
#
#  id              :bigint           not null, primary key
#  question_number :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  department_id   :bigint           not null
#  question_id     :uuid             not null
#
# Indexes
#
#  index_questions_departments_mediators_on_department_id      (department_id)
#  index_questions_departments_mediators_on_question_id        (question_id)
#  index_questions_depts_mediators_on_question_id_and_dept_id  (question_id,department_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (department_id => departments.id)
#  fk_rails_...  (question_id => questions.id)
#
require "rails_helper"

RSpec.describe QuestionsDepartmentsMediator, type: :model do
  describe "バリデーション" do
    let(:question) { create(:question, :has_a_department_with_question_number) }
    let(:department) { create(:department) }

    it "department_idがnullのとき保存できないこと" do
      questions_departments_mediator = build(:questions_departments_mediator, department: nil, question:)
      expect(questions_departments_mediator).to be_invalid
      expect(questions_departments_mediator.errors[:department]).to eq ["を指定して下さい"]
    end

    it "question_idがnullのとき保存できないこと" do
      questions_departments_mediator = build(:questions_departments_mediator, question: nil, department:)
      expect(questions_departments_mediator).to be_invalid
      expect(questions_departments_mediator.errors[:question]).to include("を指定して下さい")
    end

    it "question_idとunit_idの組は一意であること" do
      department = question.departments[0]
      questions_departments_mediator = build(:questions_departments_mediator, department:, question:)
      expect(questions_departments_mediator).to be_invalid
      expect(questions_departments_mediator.errors[:question_id]).to eq ["は既に指定した学部に登録されています。"]
    end
  end
end
