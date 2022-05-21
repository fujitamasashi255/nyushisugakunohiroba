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
#  question_id     :bigint           not null
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
FactoryBot.define do
  factory :questions_departments_mediator do
    question_number { (1..20).to_a.sample }
    department
    question
  end
end
