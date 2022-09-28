# frozen_string_literal: true

class AnswersSearchForm
  SORT_TYPES = %w[year_new updated_at_new like_many comment_new].each(&:freeze).freeze

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :specific_search_condition
  attribute :university_ids
  attribute :start_year, :integer
  attribute :end_year, :integer
  attribute :unit_ids
  attribute :tag_names, :string, default: -> { "" }
  attribute :sort_type, :string, default: -> { "year_new" }

  def search(user = nil)
    answers_search = Search::AnswersSearch.new(search_conditions.merge({ user: }))
    answers_sort = Sort::AnswersSort.new(sort_conditions)
    answers = answers_search.search
    answers_sort.sort(answers)
  end

  private

  def search_conditions
    {
      specific_search_condition:,
      tag_name_array:,
      university_ids: university_ids_no_blank,
      unit_ids: unit_ids_no_blank,
      start_year:,
      end_year:
    }
  end

  def sort_conditions
    { sort_type: }
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
end
