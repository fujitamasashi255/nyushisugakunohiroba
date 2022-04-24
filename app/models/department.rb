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
  validates :name, presence: true

  belongs_to :university
  has_many :questions_departments_mediators, dependent: :destroy
  has_many :questions, through: :questions_departments_mediators
end
