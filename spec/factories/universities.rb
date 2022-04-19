# frozen_string_literal: true

# == Schema Information
#
# Table name: universities
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_universities_on_name  (name) UNIQUE
#
FactoryBot.define do
  factory :university do
    sequence(:name) { |n| "test#{n}" }
  end
end
