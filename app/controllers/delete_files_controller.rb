# frozen_string_literal: true

class DeleteFilesController < ApplicationController
  def destroy
    answer = Answer.find(params[:answer_id])
    answer.files.purge
  end
end
