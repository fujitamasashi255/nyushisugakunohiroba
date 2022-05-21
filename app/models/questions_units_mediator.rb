# frozen_string_literal: true

# == Schema Information
#
# Table name: questions_units_mediators
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  question_id :bigint           not null
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
class QuestionsUnitsMediator < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  validates :question_id, uniqueness: { scope: :unit_id }
  validates :unit, presence: true

  belongs_to :question
  belongs_to_active_hash :unit
end
