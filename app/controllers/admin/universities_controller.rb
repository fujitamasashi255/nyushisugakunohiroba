# frozen_string_literal: true

class Admin::UniversitiesController < Admin::ApplicationController
  before_action :set_university, only: %i[show]

  def new
    @university = University.new
  end

  def create
    @university = University.new(university_params)
    if @university.save
      redirect_to [:admin, @university], success: "hoge"
    else
      flash.now[:danger] = t("messages.fail_create_univ")
      render "admin/universities/new"
    end
  end

  def show; end

  private

  def university_params
    params.require(:university).permit(:name)
  end

  def set_university
    @university = University.find(params[:id])
  end
end
