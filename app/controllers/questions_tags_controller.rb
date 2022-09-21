# frozen_string_literal: true

class QuestionsTagsController < ApplicationController
  skip_before_action :require_login

  def index
    tags_search_form = TagsSearchForm.new(tags_search_form_params)
    tags = tags_search_form.search
    render json: tags.map { |tag| { value: tag.name, taggings_count: tag.taggings_count } }
  end

  private

  def tags_search_form_params
    params.require(:tags_search_form).permit(:start_year, :end_year, :sort_type, university_ids: [], unit_ids: [])
  end
end
