# frozen_string_literal: true

module UserDecorator
  def avatar_url(version)
    case version
    when :profile
      avatar.variant(resize_to_fill: [80, 80], saver: { strip: true, quality: 60 })
    when :sidebar
      avatar.variant(resize_to_fill: [32, 32], saver: { strip: true })
    when :normal
      avatar.variant(resize_to_fill: [50, 50], saver: { strip: true })
    else
      avatar
    end
  end
end
