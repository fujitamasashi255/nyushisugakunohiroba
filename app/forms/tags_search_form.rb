# frozen_string_literal: true

class TagsSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :university_ids
  attribute :start_year, :integer
  attribute :end_year, :integer
  attribute :unit_ids

  def search(user = nil)
    answers_search = Search::AnswersSearch.new(search_conditions.merge({ user: }))
    answers = answers_search.search
    # 付けられた回数の多い順にタグを20個取得する
    answers.tag_counts_on(:tags).order(count: :desc).limit(20)
  end

  private

  def search_conditions
    {
      university_ids:,
      unit_ids:,
      start_year:,
      end_year:
    }
  end
end
