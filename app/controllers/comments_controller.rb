# frozen_string_literal: true

class CommentsController < ApplicationController
  def create
    @commentable = Answer.find(params[:answer_id])
    @comment = @commentable.comments.new(user: current_user, body: comment_params[:body])
    @comment.save
  end

  def destroy; end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
