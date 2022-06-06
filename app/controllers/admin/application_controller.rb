# frozen_string_literal: true

class Admin::ApplicationController < ApplicationController
  layout "admin/layouts/application"

  before_action :require_admin_permission

  private

  def require_admin_permission
    redirect_to root_path unless current_user.admin?
  end
end
