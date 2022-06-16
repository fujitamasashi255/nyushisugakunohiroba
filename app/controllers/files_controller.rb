# frozen_string_literal: true

class FilesController < ApplicationController
  def destroy
    answer = Answer.find(params[:answer_id])
    answer.files.purge
  end
end
