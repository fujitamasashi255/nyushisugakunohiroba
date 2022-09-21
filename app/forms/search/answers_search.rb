# frozen_string_literal: true

module Search
  class AnswersSearch < SearchBase
    attribute :user

    # user を指定した場合：ユーザーの解答を検索
    # user = nil の場合：全ユーザーの解答を検索
    def searchable_relation
      user ? user.answers : Answer.all
    end
  end
end
