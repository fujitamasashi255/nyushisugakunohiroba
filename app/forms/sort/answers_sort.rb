# frozen_string_literal: true

module Sort
  class AnswersSort < SortBase
    SORT_TYPES = %w[year_new updated_at_new like_many comment_new].each(&:freeze).freeze

    YEAR_NEW = lambda { |answers|
      Answer.joins(:question).where(answers: { id: answers.select(:id) }).select("answers.*, questions.year").order(Arel.sql("questions.year desc"))
    }
    UPDATED_AT_NEW = ->(answers) { answers.order(updated_at: :desc) }
    LIKE_MANY = ->(answers) { answers.order(likes_count: :desc) }
    COMMENT_NEW = lambda { |answers|
      sql_to_get_newest_comment_date = "COALESCE(MAX(comments.created_at), '0001-01-01')"
      Answer.left_joins(:comments).where(answers: { id: answers.select(:id) }).select("answers.*, #{sql_to_get_newest_comment_date}").group("answers.id").order(Arel.sql("#{sql_to_get_newest_comment_date} desc"))
    }
  end
end
