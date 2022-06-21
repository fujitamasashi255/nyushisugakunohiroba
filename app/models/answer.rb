# frozen_string_literal: true

# == Schema Information
#
# Table name: answers
#
#  id          :uuid             not null, primary key
#  ggb_base64  :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  question_id :uuid             not null
#  user_id     :uuid             not null
#
# Indexes
#
#  index_answers_on_question_id              (question_id)
#  index_answers_on_question_id_and_user_id  (question_id,user_id) UNIQUE
#  index_answers_on_user_id                  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#  fk_rails_...  (user_id => users.id)
#
class Answer < ApplicationRecord
  VALID_IMAGE_TYPES = ["image/png", "image/jpeg"].freeze
  VALID_CONTENT_TYPES = (Answer::VALID_IMAGE_TYPES + ["application/pdf"]).freeze

  belongs_to :user
  belongs_to :question
  has_one :tex, dependent: :destroy, as: :texable
  has_many_attached :files
  has_rich_text :point
  acts_as_taggable_on :tags

  delegate :name, to: :user, prefix: true, allow_nil: true
  delegate :year, :image, :image_url, to: :question, prefix: true, allow_nil: true

  validates \
    :files, \
    content_type: Answer::VALID_CONTENT_TYPES, \
    size: { less_than: 1.megabytes, message: "のサイズは1MB以下にして下さい" }, \
    limit: { max: 3, message: "は3つ以下にして下さい" }
end
