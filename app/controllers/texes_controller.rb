# frozen_string_literal: true

class TexesController < ApplicationController
  def destroy
    tex = Tex.find(params[:id])
    # 解答作成者でないユーザーがアクセスしたら、トップへリダイレクトする
    return unless current_user.own_answer?(tex.texable)

    tex.restore
    tex.save
  end
end
