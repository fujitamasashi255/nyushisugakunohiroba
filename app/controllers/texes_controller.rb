# frozen_string_literal: true

class TexesController < ApplicationController
  def destroy
    tex = Tex.find(params[:id])
    tex.restore
    tex.save
  end
end
