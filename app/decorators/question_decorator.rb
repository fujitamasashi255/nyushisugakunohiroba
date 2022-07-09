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
    when :twitter_card
      image.variant(resize_and_pad: [800, 418], saver: { strip: true })
    else
      image
    end
  end

  def og_description
    department_info = questions_departments_mediators.map { |qdm| "#{qdm.department.name}#{qdm.question_number}" }.join("、")
    "#{university.name}大学 #{department_info} の問題"
  end
end
