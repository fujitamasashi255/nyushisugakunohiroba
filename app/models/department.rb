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
class Department < ApplicationRecord
  # departmentを削除する前に、そのdepartmentのみに関連するquestionを削除する
  before_destroy :destroy_association_question

  validates :name, presence: true

  belongs_to :university
  has_many :questions_departments_mediators, dependent: :destroy
  has_many :questions, through: :questions_departments_mediators

  private

  def destroy_association_question
    questions.each do |question|
      question.destroy if question.departments == [self]
    end
  end
end
