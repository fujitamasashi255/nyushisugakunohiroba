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

  def og_description
    department_info = question.questions_departments_mediators.map { |qdm| "#{qdm.department.name}#{qdm.question_number}" }.join("、")
    "#{user.name}さんの#{question.university.name}大学 #{department_info} の解答"
  end

  def og_description_in_my_answer(uzer)
    department_info = question.questions_departments_mediators.map { |qdm| "#{qdm.department.name}#{qdm.question_number}" }.join("、")
    "#{uzer.name}さんの#{question.university.name}大学 #{department_info} の解答"
  end
end
