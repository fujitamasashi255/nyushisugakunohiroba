# frozen_string_literal: true

class LikesController < ApplicationController
  def create
    answer_id = params[:answer_id]
    Like.create!(user: current_user, answer_id:)
    @answer = Answer.find(answer_id)
  end

  def destroy
    Like.find(params[:id]).destroy!
    @answer = Answer.find(params[:answer_id])
  end
end
