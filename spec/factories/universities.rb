# frozen_string_literal: true

# == Schema Information
#
# Table name: universities
#
#  id            :bigint           not null, primary key
#  category      :integer          default("national_or_public"), not null
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
    category { University.categories.values.sample }
    prefecture { Prefecture.all.sample }

    trait :has_no_prefecture do
      prefecture {}
    end

    trait :without_category do
      category {}
    end

    # department_nameをnameとするdepartmentを1つ関連にもつuniversityをbuild
    # build(:university, :has_one_department, name: "hoge", department_name: "fuga")
    trait :has_one_department do
      transient do
        department_name { "department_name" }
      end

      after(:build) do |university, evaluator|
        university.departments << build(:department, name: evaluator.department_name)
      end
    end

    # 異なる名前の区分をdepartment_countsだけ関連に持つuniversityをbuild
    # build(:university, :has_departments, name: "hoge", department_counts: 5)
    trait :has_departments do
      transient do
        department_counts { 5 }
      end

      after(:build) do |university, evaluator|
        university.departments << build_list(:department, evaluator.department_counts)
      end
    end

    # 同名の区分を持つuniversityをbuild
    trait :has_same_name_departments do
      after(:build) do |university|
        2.times { university.departments << build(:department, name: "same_name") }
      end
    end
  end
end
