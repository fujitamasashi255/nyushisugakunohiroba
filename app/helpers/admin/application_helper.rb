# frozen_string_literal: true

module Admin::ApplicationHelper
  # views/admin/_sidebarでアクティブなメニューを判定
  def active_if(controller, action)
    current_page?(controller:, action:) ? "active" : ""
  end

  def active_if_by_path(*paths)
    active_link?(*paths) ? "active" : ""
  end

  def active_link?(*paths)
    paths.any? { |path| current_page?(path) }
  end
end
