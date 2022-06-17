# frozen_string_literal: true

class QuestionsSearchForm
  SORT_TYPES_ENUM = { year_new: 1, created_at_new: 2, bookmark_many: 3, like_many: 4 }.each_value(&:freeze).freeze
  SPECIFIC_CONDITIONS_ENUM = { nothing: 0, no_data: 1, all_data: 2 }.each_value(&:freeze).freeze

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :specific_search_condition, :integer, default: -> { SPECIFIC_CONDITIONS_ENUM[:nothing] }
  attribute :university_ids
  attribute :start_year, :integer
  attribute :end_year, :integer
  attribute :unit_ids
  attribute :tag_names, :string, default: -> { "" }
  attribute :sort_type, :integer, default: -> { SORT_TYPES_ENUM[:year_new] }
  # 条件表示の変数
  attribute :search_conditions, default: lambda { \
    { \
      university: "なし", \
      question_year: "なし", \
      unit: "なし", \
      tag: ["なし"] \
    } \
  }

  def search
    case specific_search_condition
    when SPECIFIC_CONDITIONS_ENUM[:no_data]
      Question.none
    when SPECIFIC_CONDITIONS_ENUM[:all_data]
      Question.with_attached_image.includes({ departments: [:university] }, :questions_units_mediators, { questions_departments_mediators: [:department] })
    when SPECIFIC_CONDITIONS_ENUM[:nothing]
      university_ids_no_blank = university_ids&.reject(&:blank?)
      unit_ids_no_blank = unit_ids&.reject(&:blank?)
      # tag_names="tag1, tag2"をtag_list=["tag1", "tag2"]へ
      tag_list = tag_names.split(",")

      relation = Question.with_attached_image.includes({ departments: [:university] }, :questions_units_mediators, { questions_departments_mediators: [:department] })

      # 大学名によるquestionの絞り込み
      if university_ids_no_blank.present?
        relation = relation.by_university_ids(university_ids_no_blank).distinct
        search_conditions[:university] = University.find(university_ids_no_blank).pluck(:name).join("、")
      end

      # 出題年によるquestionの絞り込み
      if start_year.present? & end_year.present?
        relation = relation.by_year(start_year, end_year).distinct
        search_conditions[:question_year] = "#{start_year} 年 〜 #{end_year} 年"
      end

      # 単元によるquestionの絞り込み
      if unit_ids_no_blank.present?
        relation = relation.by_unit_ids(unit_ids_no_blank).distinct
        search_conditions[:unit] = Unit.find(unit_ids_no_blank).pluck(:name).join("、")
      end

      # タグによるquestionの絞り込み
      if tag_list.present?
        relation = relation.by_tag_list(tag_list).distinct
        search_conditions[:tag] = tag_list
      end

      # 並び替え
      case sort_type
      when SORT_TYPES_ENUM[:year_new]
        relation = relation.reorder(year: :desc)
      when SORT_TYPES_ENUM[:created_at_new]
        relation = relation.reorder(created_at: :desc)
      when SORT_TYPES_ENUM[:bookmark_many]
        relation
      when SORT_TYPES_ENUM[:like_many]
        relation
      end

      relation
    end
  end
end
