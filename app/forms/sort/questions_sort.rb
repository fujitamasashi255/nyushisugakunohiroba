# frozen_string_literal: true

module Sort
  class QuestionsSort < SortBase
    YEAR_NEW = ->(questions) { questions.order(year: :desc) }
    CREATED_AT_NEW = ->(questions) { questions.order(created_at: :desc) }
    ANSWERS_MANY = ->(questions) { questions.order(answers_count: :desc) }
  end
end
