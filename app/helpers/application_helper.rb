# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  # アクティブなメニューを判定
  def active_if(*paths)
    active_link?(*paths) ? "active" : nil
  end

  def active_link?(*paths)
    paths.any? { |path| current_page?(path) }
  end

  # 並び替えリンクがアクティブかどうかを判定
  def active_sort_link_if(questions_search_form, sort_type)
    questions_search_form.attributes["sort_type"] == sort_type ? "active" : nil
  end

  # コントローラの名前空間に Admin が含まれるかどうかを判定
  def admin_controller?(controller)
    class_name = controller.class.name
    class_name.gsub("::#{class_name.demodulize}", "").include?("Admin")
  end

  # url にquestions_search_formクエリーパラメータを付与する
  def url_with_params(url, sort_type, params = {})
    uri = URI.parse(url)
    uri.query = URI.encode_www_form(questions_search_form_params_to_array(params, sort_type))
    uri.to_s
  end

  private

  def questions_search_form_params_to_array(params, sort_type)
    params_array = []
    if params.present?
      params_array << ["questions_search_form[start_year]", params[:start_year]]
      params_array << ["questions_search_form[end_year]", params[:end_year]]
      params[:unit_ids]&.each { |id| params_array << ["questions_search_form[unit_ids][]", id] }
      params[:university_ids]&.each { |id| params_array << ["questions_search_form[university_ids][]", id] }
    end
    params_array << ["questions_search_form[sort_type]", sort_type]
    params_array
  end
end
