# frozen_string_literal: true

# == Schema Information
#
# Table name: questions_units_mediators
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  question_id :uuid             not null
#  unit_id     :bigint           not null
#
# Indexes
#
#  index_questions_units_mediators_on_question_id              (question_id)
#  index_questions_units_mediators_on_question_id_and_unit_id  (question_id,unit_id) UNIQUE
#  index_questions_units_mediators_on_unit_id                  (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#
require "rails_helper"

RSpec.describe QuestionsUnitsMediator, type: :model do
  describe "バリデーション" do
    let(:question) { create(:question, :has_a_department_with_question_number) }
    let(:unit) { Unit.all.sample }

    it "unit_id、question_idがnullでないとき保存できること" do
      questions_units_mediator = build(:questions_units_mediator, unit:, question:)
      expect(questions_units_mediator).to be_valid
    end

    it "unit_idがnullのとき保存できないこと" do
      questions_units_mediator = build(:questions_units_mediator, unit: nil, question:)
      expect(questions_units_mediator).to be_invalid
      expect(questions_units_mediator.errors[:unit]).to eq ["を指定して下さい"]
    end

    it "question_idがnullのとき保存できないこと" do
      questions_units_mediator = build(:questions_units_mediator, question: nil)
      expect(questions_units_mediator).to be_invalid
      expect(questions_units_mediator.errors[:question]).to include("を指定して下さい")
    end

    it "question_idとunit_idの組は一意であること" do
      create(:questions_units_mediator, unit:, question:)
      questions_units_mediator = build(:questions_units_mediator, unit:, question:)
      expect(questions_units_mediator).to be_invalid
      expect(questions_units_mediator.errors[:question_id]).to eq ["は既に指定した単元に登録されています。"]
    end
  end
end
