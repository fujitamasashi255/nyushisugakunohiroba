# frozen_string_literal: true

class StaticPagesController < ApplicationController
  skip_before_action :require_login, only: %i[privacy terms inquiry]

  def privacy; end

  def terms; end

  def inquiry; end

  def description; end
end
