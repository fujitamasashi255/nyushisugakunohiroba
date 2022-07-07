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

  # twitter共有のためのURLを生成
  def twitter_share_url(text = nil, url = nil)
    twitter_share_url = URI.parse("https://twitter.com/intent/tweet")
    query_array = []
    query_array << ["text", text]
    query_array << ["url", url]
    query_array << ["hashtags", Settings.site.name]
    twitter_share_url.query = URI.encode_www_form(query_array)
    twitter_share_url.to_s
  end

  # SEO
  def default_meta_tags
    {
      site: Settings.site.name,
      reverse: true,
      separator: "|",
      charset: "utf-8",
      # canonical: "https://nyushisugakunohiroba#{request.fullpath}",
      og: defalut_og,
      description: "大学入試数学の問題検索・分類、解答共有ができるサービスです。",
      icon: [
        { href: image_url("favicon.png"), sizes: "16x16", type: "image/png" },
        { href: image_url("apple-touch-icon.png"), rel: "apple-touch-icon", sizes: "180x180", type: "image/png" }
      ],
      keywords: "数学,入試問題,入試数学",
      twitter: default_twitter_card
    }
  end

  private

  def defalut_og
    {
      site_name: Settings.site.name,
      title: :full_title,          # :full_title とすると、サイトに表示される <title> と全く同じものを表示できる
      description: :description,   # 上に同じ
      url: request.url,
      type: "website",
      image: image_url("ogp.png"),
      locale: "ja_JP"
    }
  end

  def default_twitter_card
    {
      card: "summary", # または summary_large_image
      site: "@nyushi__sugaku"            # twitter ID
    }
  end
end
