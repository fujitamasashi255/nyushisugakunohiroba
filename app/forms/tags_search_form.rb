# frozen_string_literal: true

class TagsSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :university_ids
  attribute :start_year, :integer
  attribute :end_year, :integer
  attribute :unit_ids

  def search_from_questions
    questions_search = Search::QuestionsSearch.new(search_conditions)
    questions = questions_search.search

    # 取得したquestionsから、付けられた回数の多い順に20個タグを取得する
    Tag.by_questions(questions).order(taggings_count: :desc).limit(20)
  end

  def search_from_answers(user)
    questions_search = Search::QuestionsSearch.new(search_conditions)
    questions = questions_search.search

    # 取得したquestionsから、付けられた回数の多い順にタグを取得する
    user.answers.by_questions(questions).tag_counts_on(:tags).order(count: :desc)
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
