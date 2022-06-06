# frozen_string_literal: true

class ApplicationController < ActionController::Base
  add_flash_types :success, :info, :warning, :danger
  before_action :require_login

  include Pagy::Backend

  def redirect_if_logged_in
    redirect_to root_path, danger: t("messages.still_logged_in") if logged_in?
  end

  def not_authenticated
    redirect_to root_path, danger: t("messages.require_login")
  end
end
