# frozen_string_literal: true

FactoryBot.define do
  factory :answer do
    point { "" }
    user
    question

    transient do
      tag_names { nil }
    end

    before(:create) do |answer, evaluator|
      answer.tag_list.add(evaluator.tag_names)
    end
  end
end
