# frozen_string_literal: true

class QuestionsSearchForm
  SORT_TYPES = %w[year_new created_at_new answers_many].each(&:freeze).freeze

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :university_ids # array
  attribute :start_year, :integer
  attribute :end_year, :integer
  attribute :unit_ids # array
  attribute :tag_names, :string, default: -> { "" }
  attribute :sort_type, :string, default: -> { "year_new" }

  def search
    questions_search = Search::QuestionsSearch.new(search_conditions)
    questions_sort = Sort::QuestionsSort.new(sort_conditions)
    questions = questions_search.search
    questions_sort.sort(questions)
  end

  private

  def search_conditions
    {
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
