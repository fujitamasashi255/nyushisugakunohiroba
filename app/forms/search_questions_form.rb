# frozen_string_literal: true

class SearchQuestionsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :university_ids
  attribute :start_year, :integer
  attribute :end_year, :integer
  attribute :unit_ids

  def search
    @condition = []
    university_ids_no_blank = university_ids&.reject(&:blank?)
    unit_ids_no_blank = unit_ids&.reject(&:blank?)
    relation = Question.with_attached_image.includes({ departments: [:university] }, :questions_units_mediators, { questions_departments_mediators: [:department] })

    # 大学名によるquestionの絞り込み
    if university_ids_no_blank.present?
      relation = relation.by_university_ids(university_ids)
      @condition << "大学「#{University.find(university_ids_no_blank).pluck(:name).join('、')}」"
    end

    # 出題年によるquestionの絞り込み
    if start_year.present? & end_year.present?
      relation = relation.by_year(start_year, end_year)
      @condition << "出題年「#{start_year} 年 〜 #{end_year} 年」"
    end

    # 単元によるquestionの絞り込み
    if unit_ids_no_blank.present?
      relation = relation.by_unit_ids(unit_ids)
      @condition << "単元「#{Unit.find(unit_ids_no_blank).pluck(:name).join('、')}」"
    end

    relation
  end

  def display_conditions
    if @condition.present?
      "#{@condition.join('／')}で検索した結果を出題年が新しい順に表示しています。"
    else
      "全ての問題を出題年が新しい順に表示しています。"
    end
  end
end
