# frozen_string_literal: true

module Admin::ApplicationHelper
  # アクティブなメニューを判定
  def active_if(*paths)
    active_link?(*paths) ? "active" : ""
  end

  def active_link?(*paths)
    paths.any? { |path| current_page?(path) }
  end

  # url にクエリーパラメータを付与する
  def url_with_params(url, params = {})
    uri = URI.parse(url)
    uri.query = URI.encode_www_form(params.to_a)
    uri.to_s
  end
end
