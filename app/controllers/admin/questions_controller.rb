# frozen_string_literal: true

class Admin::QuestionsController < Admin::ApplicationController
  before_action :set_question_association_without_tex, only: %i[show]
  before_action :set_question_association_without_image, only: %i[edit]
  before_action :set_question, only: %i[update destroy]

  def index
    @questions_search_form = QuestionsSearchForm.new(specific_search_condition: QuestionsSearchForm::SPECIFIC_CONDITIONS_ENUM[:all_data])
    @pagy, @questions = pagy(@questions_search_form.search.with_attached_image.includes({ departments: [:university] }, :questions_units_mediators, { questions_departments_mediators: [:department] }), link_extra: 'data-remote="true"')
  end

  def new
    @question = Question.new
  end

  def create
    @question = Question.new(question_params)
    set_depts_units_association_from_params
    set_tex_and_attach_image
    if @question.save
      redirect_to [:admin, @question], success: t(".success")
    else
      # レコードの新規作成に失敗したら、attach予定のimage blobを削除する
      ActiveStorage::Blob.find(@question.image.blob.id).purge if @question.image.blob.present?
      flash.now[:danger] = t(".fail")
      render "admin/questions/new"
    end
  end

  def show; end

  def edit; end

  def update
    set_tex_and_attach_image
    if update_question_transaction
      redirect_to [:admin, @question], success: t(".success")
    else
      flash.now[:danger] = t(".fail")
      render "admin/questions/edit"
    end
  end

  def destroy
    @question.destroy!
    redirect_to admin_questions_path, success: t(".success")
  end

  def search
    @questions_search_form = QuestionsSearchForm.new(questions_search_form_params)
    @pagy, @questions = pagy(@questions_search_form.search.with_attached_image.includes({ departments: [:university] }, :questions_units_mediators, { questions_departments_mediators: [:department] }), link_extra: 'data-remote="true"')
    @question_id_to_answer_id_hash_of_user = current_user&.question_id_to_answer_id_hash
    @questions_search_form_params = questions_search_form_params
    render "admin/questions/index"
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

  def questions_search_form_params
    params.require(:questions_search_form).permit(:start_year, :end_year, :sort_type, :tag_names, university_ids: [], unit_ids: [])
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

  # texのセットおよびpdf、imageのattach
  def set_tex_and_attach_image
    # texは新規作成時nil、編集時nilでない。
    if @question.tex.nil?
      @tex = @question.build_tex(tex_params)
    else
      @tex = @question.tex
      @tex.update(tex_params)
    end
    # texにpdfをattachする
    @tex.attach_pdf

    # pdfの画像をquestionにattachする
    @question.attach_question_image
  end

  # transaction

  def update_question_transaction
    Question.transaction do
      set_depts_units_association_from_params
      @question.update!(question_params)
    end
    true
  rescue ActiveRecord::RecordInvalid
    # アップデートに失敗したら、アップデート前のレコードにエラーメッセージを追加
    errors = @question.errors
    set_question_association_without_image
    @question.errors.merge!(errors)
    false
  end
end
