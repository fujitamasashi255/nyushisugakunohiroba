# frozen_string_literal: true

module SearchFormDecorator
  # frozen_string_literal: true

  # url にsearch_formクエリーパラメータを付与する
  def url_with_params(url, sort_type)
    uri = URI.parse(url)
    uri.query = URI.encode_www_form(search_form_params_to_array(self, sort_type))
    uri.to_s
  end

  def university_message
    university_ids_no_blank.present? ? University.find(university_ids_no_blank).pluck(:name).join("、") : "なし"
  end

  def question_year_message
    array = [start_year.present?, end_year.present?]
    case array
    when [true, true]
      "#{start_year} 年 〜 #{end_year} 年"
    when [true, false]
      "#{start_year} 年 〜 "
    when [false, true]
      " 〜 #{end_year} 年"
    when [false, false]
      "なし"
    end
  end

  def unit_message
    unit_ids_no_blank.present? ? Unit.find(unit_ids_no_blank).pluck(:name).join("、") : "なし"
  end

  def tag_message
    tag_name_array.present? ? tag_name_array.join("、") : "なし"
  end

  private

  def search_form_params_to_array(search_form_object, sort_type)
    params_array = []
    params_name = self.class.to_s.underscore
    params_array << ["#{params_name}[start_year]", search_form_object.start_year]
    params_array << ["#{params_name}[end_year]", search_form_object.end_year]
    search_form_object.unit_ids&.each { |id| params_array << ["#{params_name}[unit_ids][]", id] }
    search_form_object.university_ids&.each { |id| params_array << ["#{params_name}[university_ids][]", id] }
    params_array << ["#{params_name}[sort_type]", sort_type]
    params_array << ["#{params_name}[tag_names]", search_form_object.tag_names]
    params_array
  end
end
