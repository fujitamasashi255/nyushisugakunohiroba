# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  # コントローラの名前空間に Admin が含まれるかどうかを判定
  def admin_controller?(controller)
    class_name = controller.class.name
    class_name.gsub("::#{class_name.demodulize}", "").include?("Admin")
  end
end
