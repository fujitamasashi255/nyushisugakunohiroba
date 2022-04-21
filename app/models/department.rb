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
  validate :valid_unique_name_within_a_university?
  belongs_to :university

  private

  def valid_unique_name_within_a_university?
    errors.add(:base, "同じ名前の区分を登録することはできません") if university.departments.map { |item| item[:name] }.uniq.size < university.departments.size
  end
end
