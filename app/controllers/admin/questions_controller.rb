# frozen_string_literal: true

class Admin::QuestionsController < Admin::ApplicationController
  before_action :set_question, only: %i[show edit destroy update]

  def new
    @question = Question.new
    @question.departments = []
  end

  def create
    @question = Question.new(number: question_params[:number], set_year: question_params[:set_year])
    @question.departments << Department.find(question_params[:department_ids].reject(&:blank?))
    @question.add_units_to_association(question_params[:unit_ids].reject(&:blank?))
    if @question.save
      redirect_to [:admin, @question], success: t("flashes.question.success.create")
    else
      flash.now[:danger] = t("flashes.question.success.create")
      render "admin/questions/new"
    end
  end

  def show; end

  def edit; end

  def update; end

  def destroy; end

  private

  def question_params
    params.require(:question).permit(:number, :set_year, department_ids: [], unit_ids: [])
  end

  def set_question
    @question = Question.find(params[:id])
  end
end