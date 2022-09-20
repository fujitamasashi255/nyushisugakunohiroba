# frozen_string_literal: true

module Search
  class AnswersSearch < SearchBase
    attribute :user

    def searchable_relation
      user ? user.answers : Answer.all
    end
  end
end
