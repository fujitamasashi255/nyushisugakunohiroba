# frozen_string_literal: true

module Sort
  class QuestionsSort < SortBase
    SORT_TYPES = %w[year_new created_at_new answers_many].each(&:freeze).freeze

    YEAR_NEW = ->(questions) { questions.order(year: :desc) }
    CREATED_AT_NEW = ->(questions) { questions.order(created_at: :desc) }
    ANSWERS_MANY = ->(questions) { questions.order(answers_count: :desc) }
  end
end
