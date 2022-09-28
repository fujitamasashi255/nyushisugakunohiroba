# frozen_string_literal: true

class QuestionsSearchForm < QuestionsAnswersSearchFormBase
  def search
    questions_search = Search::QuestionsSearch.new(search_conditions)
    questions_sort = Sort::QuestionsSort.new(sort_conditions)
    questions = questions_search.search
    questions_sort.sort(questions)
  end
end
