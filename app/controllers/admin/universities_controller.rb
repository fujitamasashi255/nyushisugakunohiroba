# frozen_string_literal: true

class Admin::UniversitiesController < Admin::ApplicationController
  before_action :set_university_and_departments, only: %i[show edit destroy update]

  def index
    @q = University.ransack(params[:q])
    @universities = @q.result
  end

  def new
    @university = University.new
    @university.departments.new
  end

  def create
    @university = University.new(university_params)
    if @university.save
      redirect_to [:admin, @university], success: t("messages.success_create_univ")
    else
      flash.now[:danger] = t("messages.fail_create_univ")
      render "admin/universities/new"
    end
  end

  def show; end

  def edit
    @university.departments.new if @departments.blank?
  end

  def update
    if @university.update(university_params)
      redirect_to [:admin, @university], success: t("messages.success_update_univ")
    else
      flash.now[:danger] = t("messages.fail_update_univ")
      render "admin/universities/edit"
    end
  end

  def destroy
    @university.destroy!
    redirect_to admin_universities_path, success: t("messages.success_destroy_univ")
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
