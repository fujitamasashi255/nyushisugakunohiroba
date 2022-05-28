# frozen_string_literal: true

class QuestionsController < ApplicationController
  def index
    @questions_search_form = QuestionsSearchForm.new
    @pagy, @questions = pagy(Question.with_attached_image.includes({ departments: [:university] }, :questions_units_mediators))
  end

  def show
    set_question_association_without_tex
  end

  private

  def set_question_association_without_tex
    @question = Question.with_attached_image.includes({ departments: [:university] }, :questions_units_mediators).find(params[:id])
  end
end
