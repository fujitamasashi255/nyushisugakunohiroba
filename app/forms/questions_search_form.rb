# frozen_string_literal: true

class QuestionsSearchForm
  SORT_TYPES = %w[year_new created_at_new answers_many].each(&:freeze).freeze

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :specific_search_condition, :integer
  attribute :university_ids # array
  attribute :start_year, :integer
  attribute :end_year, :integer
  attribute :unit_ids # array
  attribute :tag_names, :string, default: -> { "" }
  attribute :sort_type, :string, default: -> { "year_new" }
  attribute :search_condition_messages # ハッシュ

  def search
    questions_search = Search::QuestionsSearch.new(search_conditions)
    questions_sort = Sort::QuestionsSort.new(sort_conditions)
    self.search_condition_messages = questions_search.build_search_condition_messages
    questions = questions_search.search
    questions_sort.sort(questions)
  end

  private

  def search_conditions
    {
      specific_search_condition:,
      tag_names:,
      university_ids:,
      unit_ids:,
      start_year:,
      end_year:
    }
  end

  def sort_conditions
    { sort_type: }
  end
end
