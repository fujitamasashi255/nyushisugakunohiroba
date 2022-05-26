# frozen_string_literal: true

class Admin::QuestionsSearchFormsController < Admin::ApplicationController
  def show
    @questions_search_form = QuestionsSearchForm.new(questions_search_form_params)
    @pagy, @questions = pagy(@questions_search_form.search)
    @params_to_transit = questions_search_form_params
    render "admin/questions/index"
  end

  private

  def questions_search_form_params
    params.require(:questions_search_form).permit(:start_year, :end_year, :sort_type, university_ids: [], unit_ids: [])
  end
end
