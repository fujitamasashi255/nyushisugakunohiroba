# frozen_string_literal: true

class Admin::DepartmentCheckBoxesController < Admin::ApplicationController
  def index
    university = University.find(params[:university_id])
    render json: university.departments.select(:id, :name)
  end
end
