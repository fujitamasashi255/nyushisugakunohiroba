# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    user

    transient do
      commentable { nil }
      body_text { nil }
    end

    body { ActionText::RichText.new(body: body_text) }
    commentable_id { commentable&.id }
    commentable_type { commentable&.class&.name }
  end
end
