# frozen_string_literal: true

class Admin::QuestionsController < Admin::ApplicationController
  before_action :set_question, only: %i[show edit destroy update]
  before_action :set_association, only: %i[show edit]

  def new
    @question = Question.new
    @departments = @question.departments
    @units = @question.units
  end

  def create
    @question = Question.new(number: question_params[:number], set_year: question_params[:set_year])
    @question.departments << Department.includes(:university).find(question_params[:department_ids].reject(&:blank?))
    @question.add_units_to_association(question_params[:unit_ids].reject(&:blank?))
    if @question.save
      redirect_to [:admin, @question], success: t("flashes.question.success.create")
    else
      set_form_params_in_create_fail
      flash.now[:danger] = t("flashes.question.fail.create")
      render "admin/questions/new"
    end
  end

  def show; end

  def edit; end

  def update
    if @question.update(number: question_params[:number], set_year: question_params[:set_year])
      redirect_to [:admin, @question], success: t("flashes.question.success.update")
    else
      flash.now[:danger] = t("flashes.question.fail.update")
      # render "admin/questions/edit"
    end
  end

  def destroy
    @question.destroy!
    redirect_to admin_questions_path, success: t("flashes.question.success.destroy")
  end

  private

  def question_params
    params.require(:question).permit(:number, :set_year, department_ids: [], unit_ids: [])
  end

  def set_question
    @question = Question.find(params[:id])
  end

  def set_association
    @departments = @question.departments.includes(:university)
    @university = @departments[0].university if @departments.present?
    @units = @question.units
  end

  def set_form_params_in_create_fail
    @departments = @question.departments
    @university = @departments[0].university if @departments.present?
    @units = @question.units
  end
end
