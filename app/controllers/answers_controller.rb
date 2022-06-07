# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :set_answer, only: %i[show edit update destroy]

  def index; end

  def new
    @answer = Answer.new
    @question = Question.find(params[:question_id])
  end

  def create
    @answer = current_user.answers.new(question_id: params[:question_id])
    set_tex
    if @answer.save
      @question = @answer.question
      redirect_to @answer, success: t(".success")
    else
      flash.now[:danger] = t(".fail")
      render "answers/new"
    end
  end

  def show
    @question = @answer.question
  end

  def edit
    @question = @answer.question
  end

  def update
    set_tex
    if @answer.update(answer_params)
      redirect_to @answer, success: t(".success")
    else
      flash.now[:danger] = t(".danger")
      render "answers/edit"
    end
  end

  def destroy
    @question = @answer.question
    @answer.destroy!
    redirect_to question_path(@question), success: t(".success")
  end

  private

  # def answer_params
  #   params.require(:answer).permit()
  # end

  def tex_params
    params.require(:answer).permit(tex: %i[code pdf_blob_signed_id id _destroy])[:tex]
  end

  def set_answer
    @answer = Answer.find(params[:id])
  end

  # texにpdfをattachし、texをanserに関連づける
  def set_tex
    # texは新規作成時nil、編集時nilでない。
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
