# frozen_string_literal: true

class Admin::QuestionsSortsController < Admin::ApplicationController
  def show
    @questions_search_form = QuestionsSearchForm.new(questions_search_form_params)
    @pagy, @questions = pagy(@questions_search_form.search)
    @params_to_transit = questions_search_form_params
    render "admin/questions/index"
  end

  private

  def questions_search_form_params
    if params[:questions_search_form].present?
      params.require(:questions_search_form).permit(:start_year, :end_year, university_ids: [], unit_ids: []).merge({ sort_type: QuestionsSearchForm::SORT_TYPES_ENUM[params[:sort_type].to_sym] })
    else
      { sort_type: QuestionsSearchForm::SORT_TYPES_ENUM[params[:sort_type].to_sym] }
    end
  end
end
