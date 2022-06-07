# frozen_string_literal: true

class QuestionsSortsController < ApplicationController
  skip_before_action :require_login

  def show
    @questions_search_form = QuestionsSearchForm.new(questions_search_form_params)
    @pagy, @questions = pagy(@questions_search_form.search)
    @question_id_to_answer_id_hash_of_user = current_user&.question_id_to_answer_id_hash
    if URI(request.referrer.to_s).path.include?("admin")
      render "admin/questions/index", layout: "admin/layouts/application"
    else
      render "questions/index"
    end
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
