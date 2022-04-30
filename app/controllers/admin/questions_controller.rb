# frozen_string_literal: true

class Admin::QuestionsController < Admin::ApplicationController
  before_action :set_question_association_without_tex, only: %i[show]
  before_action :set_question_association_without_image, only: %i[edit]
  before_action :set_question, only: %i[update destroy]

  def index
    @pagy, @questions = pagy(Question.with_attached_image.includes({ departments: [:university] }, :questions_units_mediators))
  end

  def new
    @question = Question.new
  end

  def create
    @question = Question.new(question_params)
    set_depts_units_univ_association_from_params
    @tex = @question.build_tex(tex_params)
    @tex.attach_pdf
    if @question.save
      attach_question_image
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
      attach_question_image
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
    params.require(:question).permit(tex: %i[code pdf_blob_signed_id id _destroy], department_ids: [], unit_ids: [])
  end

  def tex_params
    other_params[:tex]
  end

  def department_params_ids
    other_params[:department_ids].reject(&:blank?)
  end

  def unit_params_ids
    other_params[:unit_ids].reject(&:blank?)
  end

  def set_question
    Question.find(params[:id])
  end

  def set_question_association_without_tex
    @question = Question.with_attached_image.includes({ departments: [:university] }, :questions_units_mediators).find(params[:id])
  end

  def set_question_association_without_image
    @question = Question.includes({ departments: [:university] }, :questions_units_mediators).find(params[:id])
  end

  def set_depts_units_univ_association_from_params
    @departments = Department.includes(:university).find(department_params_ids)
    @units = Unit.find(unit_params_ids)
    @question.departments = @departments
    # departmentsのdepartmentがbelongs_toしている大学は同じで、それを取得する
    @university = @departments[0].university if @departments.present?
    @question.units_to_association(@units)
  end

  # @tex.pdfをpngにして、余白を取り除いた画像を@question.imageにattachする
  def attach_question_image
    @question.image.attach(@tex.pdf_to_img_blob.signed_id) if @tex.pdf.present?
  end
end
