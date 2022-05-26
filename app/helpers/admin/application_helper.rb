# frozen_string_literal: true

module Admin::ApplicationHelper
  # アクティブなメニューを判定
  def active_if(*paths)
    active_link?(*paths) ? "active" : ""
  end

  def active_link?(*paths)
    paths.any? { |path| current_page?(path) }
  end

  # url にquestions_search_formクエリーパラメータを付与する
  def url_with_params(url, params = {})
    uri = URI.parse(url)
    uri.query = URI.encode_www_form(questions_search_form_params_to_array(params))
    uri.to_s
  end

  private

  def questions_search_form_params_to_array(params)
    params_array = []
    if params.present?
      params_array << ["questions_search_form[start_year]", params[:start_year]]
      params_array << ["questions_search_form[end_year]", params[:end_year]]
      params[:unit_ids]&.each { |id| params_array << ["questions_search_form[unit_ids][]", id] }
      params[:university_ids]&.each { |id| params_array << ["questions_search_form[university_ids][]", id] }
    end
    params_array
  end
end
