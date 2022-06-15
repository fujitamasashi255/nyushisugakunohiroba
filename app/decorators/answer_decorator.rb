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
end
