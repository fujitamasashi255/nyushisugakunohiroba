# frozen_string_literal: true

class Admin::QuestionsController < Admin::ApplicationController
  def new
    @question = Question.new
  end
end
