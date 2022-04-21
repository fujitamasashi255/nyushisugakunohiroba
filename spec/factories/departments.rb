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
FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "test#{n}" }
    university
  end
end
