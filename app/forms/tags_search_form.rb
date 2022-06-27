# frozen_string_literal: true

class TagsSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :university_ids
  attribute :start_year, :integer
  attribute :end_year, :integer
  attribute :unit_ids

  def search_from_questions
    questions = Question.all

    # 大学名によるquestionの絞り込み
    questions = questions.by_university_ids(university_ids).distinct if university_ids.present?

    # 出題年によるquestionの絞り込み
    questions = questions.by_year(start_year, end_year).distinct if start_year.present? & end_year.present?

    # 単元によるquestionの絞り込み
    questions = questions.by_unit_ids(unit_ids).distinct if unit_ids.present?

    # 取得したquestionsから、付けられた回数の多い順に20個タグを取得する
    Tag.by_questions(questions).order(taggings_count: :desc).limit(20)
  end

  def search_from_answers(user)
    questions = Question.all

    # 大学名によるquestionの絞り込み
    questions = questions.by_university_ids(university_ids).distinct if university_ids.present?

    # 出題年によるquestionの絞り込み
    questions = questions.by_year(start_year, end_year).distinct if start_year.present? & end_year.present?

    # 単元によるquestionの絞り込み
    questions = questions.by_unit_ids(unit_ids).distinct if unit_ids.present?

    # 取得したquestionsから、付けられた回数の多い順にタグを取得する
    user.answers.by_questions(questions).tag_counts_on(:tags).order(count: :desc)
  end
end
