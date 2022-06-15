# frozen_string_literal: true

module QuestionDecorator
  def image_url(version = nil)
    case version
    when :show
      image.variant(resize_to_limit: [500, nil], saver: { strip: true })
    when :dropdown
      image.variant(resize_to_fit: [500, nil], saver: { strip: true })
    when :index
      image.variant(resize_to_limit: [500, nil], saver: { strip: true })
    else
      image
    end
  end
end
