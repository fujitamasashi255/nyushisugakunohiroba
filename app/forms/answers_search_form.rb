# frozen_string_literal: true

class AnswersSearchForm
  SORT_TYPES = %w[year_new updated_at_new].each(&:freeze).freeze
  SPECIFIC_CONDITIONS_ENUM = { nothing: 0, no_data: 1, all_data: 2 }.each_value(&:freeze).freeze

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :specific_search_condition, :integer, default: -> { SPECIFIC_CONDITIONS_ENUM[:nothing] }
  attribute :university_ids
  attribute :start_year, :integer
  attribute :end_year, :integer
  attribute :unit_ids
  attribute :tag_names, :string, default: -> { "" }
  attribute :sort_type, :string, default: -> { "year_new" }
  # 条件表示の変数
  attribute :search_conditions, default: lambda { \
    { \
      university: "なし", \
      question_year: "なし", \
      unit: "なし", \
      tag: "なし" \
    } \
  }

  def search(user)
    case specific_search_condition
    when SPECIFIC_CONDITIONS_ENUM[:no_data]
      relation = Answer.none
    when SPECIFIC_CONDITIONS_ENUM[:all_data]
      relation = user.answers
    when SPECIFIC_CONDITIONS_ENUM[:nothing]
      university_ids_no_blank = university_ids&.reject(&:blank?)
      unit_ids_no_blank = unit_ids&.reject(&:blank?)
      # tag_names="tag1, tag2"をtag_list=["tag1", "tag2"]へ
      tag_name_array = tag_names.split(",")

      relation = user.answers

      # 大学名によるanswerの絞り込み
      if university_ids_no_blank.present?
        relation = relation.by_university_ids(university_ids_no_blank).distinct
        search_conditions[:university] = University.find(university_ids_no_blank).pluck(:name).join("、")
      end

      # 出題年によるanswerの絞り込み
      if start_year.present? & end_year.present?
        relation = relation.by_year(start_year, end_year).distinct
        search_conditions[:question_year] = "#{start_year} 年 〜 #{end_year} 年"
      end

      # 単元によるanswerの絞り込み
      if unit_ids_no_blank.present?
        relation = relation.by_unit_ids(unit_ids_no_blank).distinct
        search_conditions[:unit] = Unit.find(unit_ids_no_blank).pluck(:name).join("、")
      end

      # タグによるanswerの絞り込み
      if tag_name_array.present?
        relation = relation.by_tag_name_array(tag_name_array).distinct
        search_conditions[:tag] = tag_name_array.join("、")
      end
    end

    # 並び替え
    case sort_type
    when "year_new"
      relation = Answer.joins(:question).where(answers: { id: relation.select(:id) }).select("answers.*, questions.year").order(Arel.sql("questions.year desc"))
    when "updated_at_new"
      relation = relation.order(updated_at: :desc)
    end

    relation
  end
end
