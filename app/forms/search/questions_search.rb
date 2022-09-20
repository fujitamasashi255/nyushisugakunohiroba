# frozen_string_literal: true

module Search
  class QuestionsSearch < SearchBase
    def searchable_relation
      Question.all
    end
  end
end
