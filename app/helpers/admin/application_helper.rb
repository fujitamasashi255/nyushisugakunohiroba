# frozen_string_literal: true

module Admin::ApplicationHelper
  # views/admin/_sidebarでアクティブなメニューを判定
  def active_if(controller, action)
    (controller == controller_path) & (action == action_name) ? "active" : ""
  end
end
