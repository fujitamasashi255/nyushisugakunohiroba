# frozen_string_literal: true

class TexesController < ApplicationController
  def destroy
    tex = Tex.find(params[:id])
    tex.clear_attributes
    tex.save
  end
end
