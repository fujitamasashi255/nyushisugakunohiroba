# frozen_string_literal: true

class TopController < ApplicationController
  skip_before_action :require_login, only: [:show]

  def show
    @questions_search_form = QuestionsSearchForm.new(specific_search_condition: QuestionsSearchForm::SPECIFIC_CONDITIONS_ENUM[:all_data], sort_type: "answers_many")
    @questions = @questions_search_form.search.limit(2).with_attached_image.includes({ departments: :university }, :questions_units_mediators, { questions_departments_mediators: :department })
    @question_id_to_answer_id_hash_of_user = logged_in? ? current_user.question_id_to_answer_id_hash : {}
    @answers = Answer.all.includes(:rich_text_point, :tags, user: { avatar_attachment: :blob }, question: { departments: :university, image_attachment: :blob }).order(created_at: :desc).limit(2)
  end
end
