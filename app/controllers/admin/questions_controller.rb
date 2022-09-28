# frozen_string_literal: true

class Admin::QuestionsController < Admin::ApplicationController
  before_action :set_question_association_without_tex, only: %i[show]
  before_action :set_question_association_without_image, only: %i[edit]

  def index
    @questions_search_form = QuestionsSearchForm.new
    @pagy, @questions = pagy(@questions_search_form.search.with_attached_image.includes({ departments: [:university] }, :questions_units_mediators, { questions_departments_mediators: [:department] }), link_extra: 'data-remote="true" class="loading page-link"')
  end

  def new
    @question = Question.new
  end

  def create
    @question = Question.new(question_params)
    set_depts_units_association_from_params
    @question.build_tex(tex_params)
    attach_tex_pdf_and_attach_question_image
    if @question.save
      redirect_to [:admin, @question], success: t(".success")
    else
      flash.now[:danger] = t(".fail")
      render "admin/questions/new"
    end
  end

  def show; end

  def edit; end

  def update
    @question = Question.find(params[:id])
    @question.tex.update(tex_params)
    # @question = Question.includes(departments: :universty).find(params[:id])
    attach_tex_pdf_and_attach_question_image
    if update_question_transaction
      redirect_to [:admin, @question], success: t(".success")
    else
      flash.now[:danger] = t(".fail")
      render "admin/questions/edit"
    end
  end

  def destroy
    @question = Question.includes(answers: [:tex, :rich_text_point, :tags, { files_attachments: :blob }]).find(params[:id])
    @question.destroy!
    redirect_to admin_questions_path, success: t(".success")
  end

  def search
    @questions_search_form = QuestionsSearchForm.new(questions_search_form_params)
    @pagy, @questions = pagy(@questions_search_form.search.with_attached_image.preload({ departments: [:university] }, :questions_units_mediators, { questions_departments_mediators: [:department] }), link_extra: 'data-remote="true" class="loading page-link"')
    @question_id_to_answer_id_hash_of_user = current_user&.question_id_to_answer_id_hash
    render "admin/questions/index"
  end

  private

  # params

  def question_params
    params.require(:question).permit(:year)
  end

  def other_params
    params.require(:question).permit(tex: %i[code compile_result_url id _destroy], department_ids: [], unit_ids: [])
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

  def questions_search_form_params
    params.require(:questions_search_form).permit(:start_year, :end_year, :sort_type, :tag_names, university_ids: [], unit_ids: [])
  end

  # set objects
  # show
  def set_question_association_without_tex
    @question = Question.with_attached_image.includes(:questions_units_mediators, { questions_departments_mediators: [department: :university] }).find(params[:id])
  end

  # edit
  def set_question_association_without_image
    @question = Question.includes(:questions_units_mediators, { questions_departments_mediators: [department: :university] }).find(params[:id])
  end

  def set_depts_units_association_from_params
    # unitの関連を設定
    @question.units_to_association(unit_params_ids)

    # departmentの関連を設定
    @question.departments_to_association(questions_departments_mediator_params[:department])
  end

  # texにpdfをattachし、、questionにimageをattachする
  def attach_tex_pdf_and_attach_question_image
    # texにpdfをattachする
    @question.tex.attach_pdf

    # pdfを画像に変換し、それをquestionにattachする
    @question.attach_image_from_pdf

    # publicのpdfファイルを削除
    pdf_path = @question.tex.compile_result_path
    file_delete_if_exist(pdf_path)
  end

  # transaction

  def update_question_transaction
    Question.transaction do
      set_depts_units_association_from_params
      @question.update!(question_params)
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end
end
