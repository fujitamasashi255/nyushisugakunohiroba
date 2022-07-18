# frozen_string_literal: true

class AnswersTagsController < ApplicationController
  def index
    tags_search_form = TagsSearchForm.new(tags_search_form_params)
    tags = tags_search_form.search_from_answers(current_user)
    render json: tags.map { |tag| { value: tag.name, count: tag.count } }
  end

  private

  def tags_search_form_params
    params.require(:tags_search_form).permit(:start_year, :end_year, :sort_type, university_ids: [], unit_ids: [])
  end
end
