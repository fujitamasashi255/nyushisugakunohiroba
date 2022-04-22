# frozen_string_literal: true

# == Schema Information
#
# Table name: questions_departments_mediators
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  department_id :bigint           not null
#  question_id   :bigint           not null
#
# Indexes
#
#  index_questions_departments_mediators_on_department_id  (department_id)
#  index_questions_departments_mediators_on_question_id    (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (department_id => departments.id)
#  fk_rails_...  (question_id => questions.id)
#
class QuestionsDepartmentsMediator < ApplicationRecord
  belongs_to :question
  belongs_to :department
end
