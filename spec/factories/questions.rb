# frozen_string_literal: true

# == Schema Information
#
# Table name: questions
#
#  id         :bigint           not null, primary key
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :question do
    year { (1980..Time.current.year).to_a.sample }

    # build(:question, :has_departments_with_question_number, year: "hoge", department_counts: 5)
    trait :has_departments_with_question_number do
      transient do
        department_counts { 5 }
        university_id { 1 }
      end

      after(:build) do |question, evaluator|
        university = create(:university, id: evaluator.university_id)
        evaluator.department_counts.times do
          department = create(:department, university:)
          question.questions_departments_mediators << build(:questions_departments_mediator, department:)
        end
      end
    end

    trait :has_no_question_number do
      after(:build) do |question|
        university = create(:university)
        department = create(:department, university:)
        question.questions_departments_mediators << build(:questions_departments_mediator, department:, question_number: nil)
      end
    end

    trait :has_different_university do
      after(:build) do |question|
        2.times do
          university = create(:university)
          department = create(:department, university:)
          question.questions_departments_mediators << build(:questions_departments_mediator, department:)
        end
      end
    end

    trait :has_same_departments do
      after(:build) do |question|
        department = create(:department)
        2.times do
          question.questions_departments_mediators << build(:questions_departments_mediator, department:)
        end
      end
    end

    trait :has_univ_id_and_unitz do
      transient do
        university_id { 1 }
        unitz { Unit.all.sample(2) }
      end

      before(:create) do |question, evaluator|
        university = create(:university, id: evaluator.university_id)
        department = create(:department, university:)
        question.questions_departments_mediators << build(:questions_departments_mediator, department:)
        evaluator.unitz.each do |unit|
          question.questions_units_mediators << build(:questions_units_mediator, unit_id: unit.id)
        end
      end
    end
  end
end
