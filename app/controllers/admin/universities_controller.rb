# frozen_string_literal: true

class Admin::UniversitiesController < Admin::ApplicationController
  before_action :set_university_and_departments, only: %i[show edit destroy update]

  def index
    @q = University.ransack(params[:q])
    @pagy, @universities = pagy(@q.result.includes(:departments))
  end

  def new
    @university = University.new
    @university.departments.new
  end

  def create
    @university = University.new(university_params)
    if @university.save
      redirect_to [:admin, @university], success: t("flashes.university.success.create")
    else
      flash.now[:danger] = t("flashes.university.fail.create")
      render "admin/universities/new"
    end
  end

  def show; end

  def edit
    @university.departments.new if @departments.blank?
  end

  def update
    if @university.update(university_params)
      redirect_to [:admin, @university], success: t("flashes.university.success.update")
    else
      flash.now[:danger] = t("flashes.university.fail.update")
      render "admin/universities/edit"
    end
  end

  def destroy
    @university.destroy!
    redirect_to admin_universities_path, success: t("flashes.university.success.destroy")
  end

  private

  def university_params
    params.require(:university).permit(:name, departments_attributes: %i[id name _destroy])
  end

  def set_university_and_departments
    @university = University.find(params[:id])
    @departments = @university.departments
  end
end
