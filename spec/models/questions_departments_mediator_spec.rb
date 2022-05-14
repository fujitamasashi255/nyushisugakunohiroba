# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuestionsDepartmentsMediator, type: :model do
  describe "バリデーション" do
    let(:question) { create(:question, :has_departments_with_question_number, department_counts: 1) }
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
