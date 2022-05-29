# frozen_string_literal: true

class QuestionsController < ApplicationController
  def index
    @questions_search_form = QuestionsSearchForm.new(specific_search_condition: QuestionsSearchForm::SPECIFIC_CONDITIONS_ENUM[:no_data])
    @pagy, @questions = pagy(@questions_search_form.search)
  end

  def show
    set_question_association_without_tex
  end

  private

  def set_question_association_without_tex
    @question = Question.with_attached_image.includes({ departments: [:university] }, :questions_units_mediators).find(params[:id])
  end
end
