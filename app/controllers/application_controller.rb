# frozen_string_literal: true

class ApplicationController < ActionController::Base
  add_flash_types :success, :info, :warning, :danger
  before_action :require_login

  include Pagy::Backend

  # current_user をdecorateできるようにする
  def current_user
    (u = super) && ActiveDecorator::Decorator.instance.decorate(u)
  end

  def redirect_if_logged_in
    redirect_to root_path, danger: t("messages.still_logged_in") if logged_in?
  end

  def not_authenticated
    redirect_to login_path, danger: t("messages.require_login")
  end

  def file_delete_if_exist(path)
    File.delete(path) if File.file?(path) && File.exist?(path)
  end
end
