# frozen_string_literal: true

class StaticPagesController < ApplicationController
  skip_before_action :require_login, only: %i[privacy terms]

  def privacy; end

  def terms; end

  def description; end
end
