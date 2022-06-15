# frozen_string_literal: true

module AnswerDecorator
  def files_urls(version = nil)
    case version
    when :show
      files.map { |file| file.variant(resize_to_limit: [600, nil], saver: { strip: true }) }
    else
      files
    end
  end
end
