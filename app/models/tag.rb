# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy

  scope :by_questions, lambda { |questions| \
    joins(:taggings)\
      .joins("INNER JOIN answers ON answers.id = taggings.taggable_id")\
      .joins("INNER JOIN questions ON answers.question_id = questions.id")\
      .distinct\
      .where(questions: { id: questions.pluck(:id) })
  }
end
