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
  VALID_IMAGE_TYPES = ["image/png", "image/jpg", "image/jpeg"].freeze
  VALID_CONTENT_TYPES = (Answer::VALID_IMAGE_TYPES + ["application/pdf"]).freeze

  after_destroy :destroy_tags
  validates :question_id, uniqueness: { scope: :user_id, message: "解答は既に作成されています" }
  validates \
    :files, \
    content_type: { in: Answer::VALID_CONTENT_TYPES, message: "の種類が正しくありません" }, \
    size: { less_than: 1.megabytes, message: "のサイズは1MB以下にして下さい" }, \
    limit: { max: 3, message: "は3つ以下にして下さい" }

  belongs_to :user
  belongs_to :question
  has_one :tex, dependent: :destroy, as: :texable
  has_many_attached :files
  has_rich_text :point
  acts_as_taggable_on :tags

  delegate :name, to: :user, prefix: true, allow_nil: true
  delegate :year, :image, :image_url, to: :question, prefix: true, allow_nil: true

  scope :by_university_ids, ->(university_ids) { joins(question: { departments: :university }).where(universities: { id: university_ids }).distinct }
  scope :by_year, ->(start_year, end_year) { joins(:question).where(questions: { year: start_year..end_year }) }
  scope :by_unit_ids, ->(unit_ids) { joins(question: :questions_units_mediators).where(questions_units_mediators: { unit_id: unit_ids }).distinct }
  scope :by_tag_name_array, lambda { |tag_name_array|
    joins("INNER JOIN taggings ON answers.id = taggings.taggable_id")\
      .joins("INNER JOIN tags ON tags.id = taggings.tag_id")\
      .where(tags: { name: tag_name_array })\
      .distinct
  }
  scope :by_questions, ->(questions) { where(question_id: questions.map(&:id)) }

  private

  def destroy_tags
    tags.each do |tag|
      tag.destroy if tag.taggings_count == 1
    end
  end
end
