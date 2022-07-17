# frozen_string_literal: true

class Answers::FilesController < ApplicationController
  def destroy
    answer = Answer.find(params[:answer_id])
    # 解答作成者でないユーザーがアクセスしたら、処理を行わない
    return unless current_user.own_answer?(answer)

    answer.files.purge if answer.files.attached?
  end
end
