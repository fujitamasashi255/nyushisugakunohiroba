# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :set_answer, only: %i[show edit update destroy]
  before_action :set_question, only: %i[new create show edit update destroy]

  def index; end

  def new
    answer_id = current_user.question_id_to_answer_id_hash[@question.id]
    if answer_id
      # 当該の問題の解答を既に作成している場合は編集ページへredirect
      redirect_to edit_answer_path(answer_id)
    else
      # 解答未作成の場合は新規作成ページへ
      @answer = Answer.new
      @tex = @answer.build_tex
    end
  end

  def create
    @answer = current_user.answers.new(question_id: params[:question_id], point: answer_params[:point], tag_list: answer_params[:tag_list], files: answer_params[:files])
    set_tex
    if @answer.save
      redirect_to @answer, success: t(".success")
    else
      # save失敗時は必ずfilesが不正なので、それをnilにする
      @answer.files = nil
      flash.now[:danger] = t(".fail")
      render "answers/new"
    end
  end

  def show; end

  def edit; end

  def update
    set_tex
    if @answer.update(answer_params)
      redirect_to @answer, success: t(".success")
    else
      # update失敗はファイル登録失敗時のみ
      # ファイル登録失敗時は、エラーメッセージと共に、元々登録されていたファイルを表示する
      errors = @answer.errors
      set_answer
      errors[:files].each { |error| @answer.errors.add(:files, error) }
      flash.now[:danger] = t(".fail")
      render "answers/edit"
    end
  end

  def destroy
    @answer.destroy!
    redirect_to question_path(@question), success: t(".success")
  end

  private

  def answer_params
    params.require(:answer).permit(:point, :tag_list, files: [])
  end

  def tex_params
    params.require(:answer).permit(tex: %i[code pdf_blob_signed_id id _destroy])[:tex]
  end

  def set_answer
    @answer = Answer.includes(question: { departments: [:university] }).with_attached_files.find(params[:id])
  end

  def set_question
    @question = if params[:question_id]
                  Question.includes({ departments: [:university] }).find(params[:question_id])
                else
                  @answer.question
                end
  end

  # texにpdfをattachし、texをanserに関連づける
  def set_tex
    if @answer.tex.nil?
      @tex = @answer.build_tex(tex_params)
    else
      @tex = @answer.tex
      @tex.update(tex_params)
    end
    # texにpdfをattachする
    @tex.attach_pdf
  end
end
