# frozen_string_literal: true

module AnswerDecorator
  def files_urls(version = nil)
    case version
    when :show
      files.map do |file|
        if file.content_type == "application/pdf"
          file
        elsif Answer::VALID_IMAGE_TYPES.include?(file.content_type)
          file.variant(resize_to_limit: [600, nil], saver: { strip: true })
        end
      end
    else
      files
    end
  end

  def tex_collapse_message
    if tex.pdf.attached?
      content = content_tag(:span, I18n.t(".decorators.answer.close"))
      content << content_tag(:i, nil, class: ["bi", "bi-chevron-up ms-2"])
    else
      content = content_tag(:span, I18n.t(".decorators.answer.open"))
      content << content_tag(:i, nil, class: ["bi", "bi-chevron-down ms-2"])
    end
    content
  end

  def contents_present?
    tags.present? || point.present? || files.attached? || tex.pdf.attached?
  end
end
