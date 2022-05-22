# frozen_string_literal: true

module Admin::ApplicationHelper
  # アクティブなメニューを判定
  def active_if(*paths)
    active_link?(*paths) ? "active" : ""
  end

  def active_link?(*paths)
    paths.any? { |path| current_page?(path) }
  end
end
