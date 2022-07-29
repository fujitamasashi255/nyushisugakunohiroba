# frozen_string_literal: true

class CommentsController < ApplicationController
  skip_before_action :require_login, only: %i[index] # コメント一覧はログイン不要

  def index
    @pagy, @comments = pagy_countless(Comment.where(commentable_id: params[:answer_id], commentable_type: "Answer").order(created_at: :desc).includes(:rich_text_body, user: { avatar_attachment: :blob }), items: 10, link_extra: 'data-remote="true"')
  end

  def create
    @commentable = Answer.find(params[:answer_id])
    @comment = @commentable.comments.new(user: current_user, body: comment_params[:body])
    @comment.save
  end

  def show
    @comment = Comment.find(params[:id])
    render "comments/update"
  end

  def edit
    @comment = Comment.find(params[:id])
  end

  def update
    @comment = Comment.find(params[:id])
    @comment.update(comment_params)
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy!
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
