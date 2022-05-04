# frozen_string_literal: true

class SearchQuestionsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :university_ids
  attribute :start_year, :integer
  attribute :end_year, :integer
  attribute :unit_ids

  def search
    relation = Question.with_attached_image.includes({ departments: [:university] }, :questions_units_mediators, { questions_departments_mediators: [:department] })

    # 大学名によるquestionの絞り込み
    relation = relation.by_university_ids(university_ids) if university_ids&.reject(&:blank?).present?

    # 出題年によるquestionの絞り込み
    relation = relation.by_year(start_year, end_year) if start_year.present? & end_year.present?

    # 単元によるquestionの絞り込み
    relation = relation.by_unit_ids(unit_ids) if unit_ids&.reject(&:blank?).present?

    relation
  end
end
