# frozen_string_literal: true

class Admin::SearchQuestionsFormsController < Admin::ApplicationController
  def show
    @search_questions_form = SearchQuestionsForm.new(search_form_params)
    @pagy, @questions = pagy(@search_questions_form.search)
    render "admin/questions/index"
  end

  private

  def search_form_params
    params.require(:search_questions_form).permit(:start_year, :end_year, :sort_type, university_ids: [], unit_ids: [])
  end
end
