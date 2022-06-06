# frozen_string_literal: true

class Admin::ApplicationController < ApplicationController
  layout "admin/layouts/application"

  before_action :require_admin_permission

  private

  def require_admin_permission
    not_authenticated unless current_user.admin?
  end
end
