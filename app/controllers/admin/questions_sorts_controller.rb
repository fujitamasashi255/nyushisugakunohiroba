# frozen_string_literal: true

class Admin::QuestionsSortsController < Admin::ApplicationController
  skip_before_action :delete_search_condition_cookies

  def show
    @questions_search_form = QuestionsSearchForm.new(search_conditions)
    @pagy, @questions = pagy(@questions_search_form.search)
    render "admin/questions/index"
  end

  private

  def search_conditions
    university_ids = JSON.parse(cookies[:university_ids]) if cookies[:university_ids].present?
    unit_ids = JSON.parse(cookies[:unit_ids]) if cookies[:unit_ids].present?
    {
      university_ids:,
      unit_ids:,
      start_year: cookies[:start_year],
      end_year: cookies[:end_year],
      sort_type: QuestionsSearchForm::SORT_TYPES_ENUM[params[:sort_type].to_sym]
    }
  end
end
