# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  # アクティブなメニューを判定
  def active_if(*paths)
    active_link?(*paths) ? "active" : nil
  end

  def active_link?(*paths)
    paths.any? { |path| current_page?(path) }
  end

  # 並び替えリンクがアクティブかどうかを判定
  def active_sort_link_if(search_form_object, sort_type)
    search_form_object.sort_type == sort_type ? "active" : nil
  end

  # コントローラの名前空間に Admin が含まれるかどうかを判定
  def admin_controller?(controller)
    class_name = controller.class.name
    class_name.gsub("::#{class_name.demodulize}", "").include?("Admin")
  end
end
