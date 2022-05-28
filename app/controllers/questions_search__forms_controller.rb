# frozen_string_literal: true

class QuestionsSearchFormsController < ApplicationController
  def show
    @questions_search_form = QuestionsSearchForm.new(questions_search_form_params)
    @pagy, @questions = pagy(@questions_search_form.search)
    @questions_search_form_params = questions_search_form_params
    if URI(request.referrer.to_s).path.include?("admin")
      render "admin/questions/index", layout: "admin/layouts/application"
    else
      render "questions/index"
    end
  end

  private

  def questions_search_form_params
    params.require(:questions_search_form).permit(:start_year, :end_year, :sort_type, university_ids: [], unit_ids: [])
  end
end
