# frozen_string_literal: true

class Admin::QuestionsController < Admin::ApplicationController
  before_action :set_question_association_without_tex, only: %i[show]
  before_action :set_question_association_without_image, only: %i[edit]
  before_action :set_question, only: %i[update destroy]

  def index
    @questions_search_form = QuestionsSearchForm.new
    @pagy, @questions = pagy(Question.with_attached_image.includes({ departments: [:university] }, :questions_units_mediators))
  end

  def new
    @question = Question.new
  end

  def create
    @question = Question.new(question_params)
    set_depts_units_association_from_params
    @tex = @question.build_tex(tex_params)
    @tex.attach_pdf
    if @question.save
      @question.attach_question_image
      redirect_to [:admin, @question], success: t("flashes.question.success.create")
    else
      flash.now[:danger] = t("flashes.question.fail.create")
      render "admin/questions/new"
    end
  end

  def show; end

  def edit; end

  def update
    @tex = @question.tex
    @tex.update(tex_params)
    @tex.attach_pdf
    if update_question_transaction
      @question.attach_question_image
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

  # params

  def question_params
    params.require(:question).permit(:year)
  end

  def other_params
    params.require(:question).permit(tex: %i[code pdf_blob_signed_id id _destroy], department_ids: [], unit_ids: [])
  end

  def tex_params
    other_params[:tex]
  end

  def questions_departments_mediator_params
    params.require(:question).permit(department: [questions_departments_mediator: [:question_number]])
  end

  def department_params_ids
    other_params[:department_ids].reject(&:blank?)
  end

  def unit_params_ids
    other_params[:unit_ids].reject(&:blank?)
  end

  # set objects

  def set_question
    @question = Question.find(params[:id])
  end

  def set_question_association_without_tex
    @question = Question.with_attached_image.includes({ departments: [:university] }, :questions_units_mediators).find(params[:id])
  end

  def set_question_association_without_image
    @question = Question.includes({ departments: [:university, :questions_departments_mediators] }, :questions_units_mediators).find(params[:id])
  end

  def set_depts_units_association_from_params
    # unitの関連を設定
    @question.units_to_association(unit_params_ids)

    # departmentの関連を設定
    @question.departments_to_association(questions_departments_mediator_params[:department])
  end

  # transaction

  def update_question_transaction
    Question.transaction do
      set_depts_units_association_from_params
      @question.update!(question_params)
    end
    true
  rescue ActiveRecord::RecordInvalid
    errors = @question.errors
    set_question_association_without_image
    @question.errors.merge!(errors)
    false
  end
end
