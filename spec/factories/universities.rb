# frozen_string_literal: true

# == Schema Information
#
# Table name: universities
#
#  id            :bigint           not null, primary key
#  category      :integer          default(0), not null
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  prefecture_id :bigint
#
# Indexes
#
#  index_universities_on_name  (name) UNIQUE
#
FactoryBot.define do
  factory :university do
    sequence(:name) { |n| "test#{n}" }

    # create(:university, :has_one_department, name: "hoge", department_name: "fuga")
    trait :has_one_department do
      transient do
        department_name { "department_name" }
      end

      after(:create) do |university, evaluator|
        university.departments << create(:department, name: evaluator.department_name)
      end
    end

    # create(:university, :has_departments, name: "hoge", department_counts: 5)
    trait :has_departments do
      transient do
        department_counts { 5 }
      end

      after(:create) do |university, evaluator|
        university.departments << create_list(:department, evaluator.department_counts)
      end
    end
  end
end
