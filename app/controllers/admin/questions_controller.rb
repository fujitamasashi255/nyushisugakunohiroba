# frozen_string_literal: true

class Admin::QuestionsController < Admin::ApplicationController
  before_action :set_question, only: %i[update destroy]
  before_action :set_objects, only: %i[show edit]

  def index; end

  def new
    @question = Question.new
    @departments = @question.departments
    @units = @question.units
    @tex = @question.build_tex
  end

  def create
    @question = Question.new(question_params)
    set_depts_units_univ_association_from_params
    @tex = @question.build_tex(tex_params)
    @tex.attach_pdf
    if @question.save
      redirect_to [:admin, @question], success: t("flashes.question.success.create")
    else
      flash.now[:danger] = t("flashes.question.fail.create")
      render "admin/questions/new"
    end
  end

  def show; end

  def edit; end

  def update
    set_depts_units_univ_association_from_params
    @tex = @question.tex
    @tex.update(tex_params)
    @tex.attach_pdf
    if @question.update(question_params)
      redirect_to [:admin, @question], success: t("flashes.question.success.update")
    else
      flash.now[:danger] = t("flashes.question.fail.update")
      render "admin/questions/edit"
    end
  end

  def destroy
    @question.destroy!
    redirect_to admin_questions_path, success: t("flashes.question.success.destroy")
  end

  private

  def question_params
    params.require(:question).permit(:number, :set_year)
  end

  def other_params
    params.require(:question).permit(tex_attributes: %i[code pdf_blob_signed_id id _destroy], department_ids: [], unit_ids: [])
  end

  def tex_params
    other_params[:tex_attributes]
  end

  def department_params_ids
    other_params[:department_ids].reject(&:blank?)
  end

  def unit_params_ids
    other_params[:unit_ids].reject(&:blank?)
  end

  def set_question
    @question = Question.find(params[:id])
  end

  def set_depts_units_univ_association_from_params
    @departments = Department.includes(:university).find(department_params_ids)
    @units = Unit.find(unit_params_ids)
    @question.departments = @departments
    @university = @departments[0].university
    @question.units_to_association(@units)
  end

  def set_objects
    @question = Question.find(params[:id])
    @departments = @question.departments.includes(:university)
    @university = @departments[0].university
    @units = @question.units
    @tex = @question.tex
  end
end
