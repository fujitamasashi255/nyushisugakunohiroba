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
  attribute :search_condition_messages

  def search(user)
    answers_search = Search::AnswersSearch.new(search_conditions.merge({ user: }))
    answers_sort = Sort::AnswersSort.new(sort_conditions)
    self.search_condition_messages = answers_search.build_search_condition_messages
    answers = answers_search.search
    answers_sort.sort(answers)
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
