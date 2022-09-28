# frozen_string_literal: true

class AnswersSearchForm < QuestionsAnswersSearchFormBase
  def search(user = nil)
    answers_search = Search::AnswersSearch.new(search_conditions.merge({ user: }))
    answers_sort = Sort::AnswersSort.new(sort_conditions)
    answers = answers_search.search
    answers_sort.sort(answers)
  end
end
