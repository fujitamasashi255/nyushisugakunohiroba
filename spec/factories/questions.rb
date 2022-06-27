# frozen_string_literal: true

# == Schema Information
#
# Table name: questions
#
#  id         :uuid             not null, primary key
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :question do
    year { (1980..Time.current.year).to_a.sample }
    image { Rack::Test::UploadedFile.new(Rails.root.join("spec/files/test.png"), "image/png") }

    # build(:question, :has_a_department_with_question_number, year: "hoge", department: fuga, question_number: 1)
    trait :has_a_department_with_question_number do
      transient do
        department { create(:department) }
        question_number { 1 }
      end

      after(:build) do |question, evaluator|
        question.questions_departments_mediators << build(:questions_departments_mediator, department: evaluator.department, question_number: evaluator.question_number)
      end
    end

    trait :has_two_departments_with_question_number do
      transient do
        department1 { nil }
        question_number1 { 1 }
        department2 { nil }
        question_number2 { 1 }
      end

      after(:build) do |question, evaluator|
        question.questions_departments_mediators << build(:questions_departments_mediator, question_number: evaluator.question_number1, department: evaluator.department1)
        question.questions_departments_mediators << build(:questions_departments_mediator, question_number: evaluator.question_number2, department: evaluator.department2)
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

    # create(:question, :full_custom, year: 2000, department: department, question_number: 10, unit:"数と式・集合と論理")
    trait :full_custom do
      transient do
        department { department { create(:department) } }
        question_number { 10 }
        unit { "数と式・集合と論理" }
      end

      before(:create) do |question, evaluator|
        question.questions_departments_mediators << build(:questions_departments_mediator, department: evaluator.department, question_number: evaluator.question_number)
        unit = Unit.find_by(name: evaluator.unit)
        question.questions_units_mediators << build(:questions_units_mediator, unit:)
      end
    end
  end
end
