# frozen_string_literal: true

module QuestionsSearchFormDecorator
  # url にquestions_search_formクエリーパラメータを付与する
  def url_with_params(url, sort_type)
    uri = URI.parse(url)
    uri.query = URI.encode_www_form(questions_search_form_params_to_array(self, sort_type))
    uri.to_s
  end

  private

  def questions_search_form_params_to_array(search_form_object, sort_type)
    params_array = []
    params_array << ["questions_search_form[start_year]", search_form_object.start_year]
    params_array << ["questions_search_form[end_year]", search_form_object.end_year]
    search_form_object.unit_ids&.each { |id| params_array << ["questions_search_form[unit_ids][]", id] }
    search_form_object.university_ids&.each { |id| params_array << ["questions_search_form[university_ids][]", id] }
    params_array << ["questions_search_form[sort_type]", sort_type]
    params_array << ["questions_search_form[tag_names]", search_form_object.tag_names]
    params_array
  end
end
