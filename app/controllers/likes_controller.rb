# frozen_string_literal: true

class LikesController < ApplicationController
  def create
    answer_id = params[:answer_id]
    like = Like.create!(user: current_user, answer_id:)
    answer = Answer.find(answer_id)
    render json: { destroy_path: answer_like_path(answer, like) }
  end

  def destroy
    Like.find(params[:id]).destroy!
    answer = Answer.find(params[:answer_id])
    render json: { create_path: answer_likes_path(answer) }
  end
end
