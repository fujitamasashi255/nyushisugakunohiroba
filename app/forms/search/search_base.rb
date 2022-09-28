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
    attribute :tag_name_array

    def initialize(attributes = {})
      super(attributes)
      after_initialize
    end

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
        relation = relation.by_university_ids(university_ids) if university_ids.present?

        # 出題年による絞り込み
        if start_year.present? || end_year.present?
          fill_in_year
          relation = relation.by_year(start_year, end_year)
        end

        # 単元による絞り込み
        relation = relation.by_unit_ids(unit_ids) if unit_ids.present?

        # タグによる絞り込み
        relation = relation.by_tag_name_array(tag_name_array) if tag_name_array.present?
      end

      relation
    end

    private

    def after_initialize
      fill_in_year
    end

    def fill_in_year
      self.start_year = 0 if start_year.blank?
      self.end_year = 3000 if end_year.blank?
    end

    def searchable_relation
      nil
    end
  end
end
