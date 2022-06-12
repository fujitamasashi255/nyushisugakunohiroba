# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def answer_carousel_inner_height(files_counts)
    files_counts.zero? ? "" : "height: 500px"
  end
end
