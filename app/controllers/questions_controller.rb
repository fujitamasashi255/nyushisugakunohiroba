# frozen_string_literal: true

class QuestionsController < ApplicationController
  skip_before_action :require_login

  def index
    @questions_search_form = QuestionsSearchForm.new(specific_search_condition: QuestionsSearchForm::SPECIFIC_CONDITIONS_ENUM[:all_data])
    @pagy, @questions = pagy(@questions_search_form.search.with_attached_image.includes({ departments: :university }, :questions_units_mediators, { questions_departments_mediators: :department }), link_extra: 'data-remote="true"')
    @question_id_to_answer_id_hash_of_user = logged_in? ? current_user.question_id_to_answer_id_hash : {}
  end

  def show
    # @question = Question.with_attached_image.includes({ departments: [:university] }, :questions_units_mediators).find(params[:id])
    @question = Question.find(params[:id])
    @question_id_to_answer_id_hash_of_user = logged_in? ? current_user.question_id_to_answer_id_hash : {}
    @pagy, @other_users_answers = pagy(@question.answers.includes(:rich_text_point, :tags, user: { avatar_attachment: :blob }).where.not(user_id: current_user&.id), link_extra: 'data-remote="true"')
  end

  def search
    @questions_search_form = QuestionsSearchForm.new(questions_search_form_params)
    @pagy, @questions = pagy(@questions_search_form.search.preload({ departments: :university }, :questions_units_mediators, { questions_departments_mediators: :department }, { image_attachment: :blob }), link_extra: 'data-remote="true"')
    @question_id_to_answer_id_hash_of_user = logged_in? ? current_user.question_id_to_answer_id_hash : {}
    render "questions/index"
  end

  private

  def questions_search_form_params
    params.require(:questions_search_form).permit(:start_year, :end_year, :tag_names, :sort_type, university_ids: [], unit_ids: [])
  end
end
