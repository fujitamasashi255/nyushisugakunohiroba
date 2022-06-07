# frozen_string_literal: true

class QuestionsController < ApplicationController
  skip_before_action :require_login

  def index
    @questions_search_form = QuestionsSearchForm.new(specific_search_condition: QuestionsSearchForm::SPECIFIC_CONDITIONS_ENUM[:no_data])
    @pagy, @questions = pagy(@questions_search_form.search)
    @question_id_to_answer_id_hash_of_user = current_user&.question_id_to_answer_id_hash
  end

  def show
    set_question_association_without_tex
    @question_id_to_answer_id_hash_of_user = current_user&.question_id_to_answer_id_hash
  end

  private

  def set_question_association_without_tex
    @question = Question.with_attached_image.includes({ departments: [:university] }, :questions_units_mediators).find(params[:id])
  end
end
