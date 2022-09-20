# frozen_string_literal: true

module Search
  class SearchBase
    SPECIFIC_CONDITIONS = { no_data: 0, all_data: 1 }.each_value(&:freeze).freeze

    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :specific_search_condition, :integer
    attribute :university_ids
    attribute :start_year, :integer
    attribute :end_year, :integer
    attribute :unit_ids
    attribute :tag_names, :string

    def search
      # 絞り込み
      case specific_search_condition
      when SPECIFIC_CONDITIONS[:no_data]
        relation = searchable_relation.none
      when SPECIFIC_CONDITIONS[:all_data]
        relation = searchable_relation
      else
        relation = searchable_relation

        # 大学名による絞り込み
        relation = relation.by_university_ids(university_ids_no_blank) if university_ids_no_blank.present?

        # 出題年による絞り込み
        if start_year.present? || end_year.present?
          fill_in_year
          relation = relation.by_year(start_year, end_year)
        end

        # 単元による絞り込み
        relation = relation.by_unit_ids(unit_ids_no_blank) if unit_ids_no_blank.present?

        # タグによる絞り込み
        relation = relation.by_tag_name_array(tag_name_array) if tag_name_array.present?
      end

      relation
    end

    def build_search_condition_messages
      { university: university_message,
        question_year: question_year_message,
        unit: unit_message,
        tag: tag_message }
    end

    private

    def searchable_relation
      nil
    end

    def university_ids_no_blank
      university_ids&.reject(&:blank?)
    end

    def unit_ids_no_blank
      unit_ids&.reject(&:blank?)
    end

    def tag_name_array
      tag_names&.split(",") # tag_names="tag1, tag2"をtag_list=["tag1", "tag2"]へ
    end

    def university_message
      university_ids_no_blank.present? ? University.find(university_ids_no_blank).pluck(:name).join("、") : "なし"
    end

    def question_year_message
      array = [start_year.present?, end_year.present?]
      case array
      when [true, true]
        "#{start_year} 年 〜 #{end_year} 年"
      when [true, false]
        "#{start_year} 年 〜 "
      when [false, true]
        " 〜 #{end_year} 年"
      when [false, false]
        "なし"
      end
    end

    def unit_message
      unit_ids_no_blank.present? ? Unit.find(unit_ids_no_blank).pluck(:name).join("、") : "なし"
    end

    def tag_message
      tag_name_array.present? ? tag_name_array.join("、") : "なし"
    end

    def fill_in_year
      self.start_year = 0 if start_year.blank?
      self.end_year = Time.current.year if end_year.blank?
    end
  end
end
