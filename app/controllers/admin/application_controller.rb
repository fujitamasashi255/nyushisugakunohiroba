# frozen_string_literal: true

class Admin::ApplicationController < ApplicationController
  layout "admin/layouts/application"
  before_action :delete_search_condition_cookies

  private

  def delete_search_condition_cookies
    cookies.delete(:university_ids)
    cookies.delete(:unit_ids)
    cookies.delete(:start_year)
    cookies.delete(:end_year)
  end
end
