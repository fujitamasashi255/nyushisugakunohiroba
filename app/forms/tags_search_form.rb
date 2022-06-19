# frozen_string_literal: true

class TagsSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :university_ids
  attribute :start_year, :integer
  attribute :end_year, :integer
  attribute :unit_ids

  def search
    university_ids_no_blank = university_ids&.reject(&:blank?)
    unit_ids_no_blank = unit_ids&.reject(&:blank?)

    # 条件からまずquestionを絞り込む
    questions = Question.all

    # 大学名によるquestionの絞り込み
    questions = questions.by_university_ids(university_ids_no_blank).distinct if university_ids_no_blank.present?

    # 出題年によるquestionの絞り込み
    questions = questions.by_year(start_year, end_year).distinct if start_year.present? & end_year.present?

    # 単元によるquestionの絞り込み
    questions = questions.by_unit_ids(unit_ids_no_blank).distinct if unit_ids_no_blank.present?

    # 取得したquestionsから、付けられた回数の多い20個のタグを取得する
    Tag.all.by_questions(questions).order(taggings_count: :desc).limit(20)
  end
end
