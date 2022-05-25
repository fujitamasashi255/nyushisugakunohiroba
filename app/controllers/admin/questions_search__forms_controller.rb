# frozen_string_literal: true

class Admin::QuestionsSearchFormsController < Admin::ApplicationController
  def show
    search_conditions_to_cookies
    @questions_search_form = QuestionsSearchForm.new(questions_search_form_params)
    @pagy, @questions = pagy(@questions_search_form.search)
    @params_to_transit = questions_search_form_params.to_h
    render "admin/questions/index"
  end

  private

  def questions_search_form_params
    params.require(:questions_search_form).permit(:start_year, :end_year, :sort_type, university_ids: [], unit_ids: [])
  end

  def search_conditions_to_cookies
    cookies[:university_ids] = JSON.generate(questions_search_form_params[:university_ids])
    cookies[:unit_ids] = JSON.generate(questions_search_form_params[:unit_ids])
    cookies[:start_year] = questions_search_form_params[:start_year]
    cookies[:end_year] = questions_search_form_params[:end_year]
  end
end
