# frozen_string_literal: true

class QuestionsSearchForm
  SORT_TYPES_ENUM = { year_new: 1, created_at_new: 10 }.each_value(&:freeze).freeze

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :university_ids
  attribute :start_year, :integer
  attribute :end_year, :integer
  attribute :unit_ids
  attribute :sort_type, :integer, default: -> { SORT_TYPES_ENUM[:year_new] }

  def initialize(params = {})
    # 条件表示の変数
    @search_conditions = []
    @sort_condition = I18n.t("activemodel.attributes.questions_search_form.sort_type.year_new")
    super(params)
  end

  def search
    university_ids_no_blank = university_ids&.reject(&:blank?)
    unit_ids_no_blank = unit_ids&.reject(&:blank?)

    relation = Question.with_attached_image.includes({ departments: [:university] }, :questions_units_mediators, { questions_departments_mediators: [:department] })

    # 大学名によるquestionの絞り込み
    if university_ids_no_blank.present?
      relation = relation.by_university_ids(university_ids).distinct
      @search_conditions << "#{University.model_name.human}「#{University.find(university_ids_no_blank).pluck(:name).join('、')}」"
    end

    # 出題年によるquestionの絞り込み
    if start_year.present? & end_year.present?
      relation = relation.by_year(start_year, end_year).distinct
      @search_conditions << "#{Question.human_attribute_name(:year)}「#{start_year} 年 〜 #{end_year} 年」"
    end

    # 単元によるquestionの絞り込み
    if unit_ids_no_blank.present?
      relation = relation.by_unit_ids(unit_ids).distinct
      @search_conditions << "#{Unit.model_name.human}「#{Unit.find(unit_ids_no_blank).pluck(:name).join('、')}」"
    end

    # 並び替え
    case sort_type
    when SORT_TYPES_ENUM[:year_new]
      relation = relation.reorder(year: :desc)
      @sort_condition = I18n.t("activemodel.attributes.questions_search_form.sort_type.year_new")
    when SORT_TYPES_ENUM[:created_at_new]
      relation = relation.reorder(created_at: :desc)
      @sort_condition = I18n.t("activemodel.attributes.questions_search_form.sort_type.created_at_new")
    end

    relation
  end

  def display_search_conditions
    if @search_conditions.present?
      @search_conditions.join("／")
    else
      "なし"
    end
  end
end
