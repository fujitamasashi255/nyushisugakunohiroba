# frozen_string_literal: true

# == Schema Information
#
# Table name: answers
#
#  id             :uuid             not null, primary key
#  comments_count :integer          default(0), not null
#  ggb_base64     :text
#  likes_count    :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  question_id    :uuid             not null
#  user_id        :uuid             not null
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
  MAX_TAGS_TOTAL_WORD_COUNT = 100

  after_destroy :destroy_tags
  validates :question_id, uniqueness: { scope: :user_id, message: "の解答は既に作成されています" }
  validates \
    :files, \
    content_type: { in: Answer::VALID_CONTENT_TYPES, message: "の種類が正しくありません" }, \
    size: { less_than: 3.megabytes, message: "のサイズは3MB以下にして下さい" }, \
    limit: { max: 3, message: "は3つ以下にして下さい" }
  validates :point, action_text_length: { maximum: 1000 }
  validate :validate_tags_total_word_count_length

  belongs_to :user
  belongs_to :question
  counter_culture :question
  has_one :tex, dependent: :destroy, as: :texable
  has_many :comments, dependent: :destroy, as: :commentable
  has_many :likes, dependent: :destroy
  has_many_attached :files
  has_rich_text :point
  acts_as_taggable_on :tags

  attribute :files_position

  delegate :name, to: :user, prefix: true, allow_nil: true
  delegate :year, :image, :image_url, to: :question, prefix: true, allow_nil: true

  scope :by_university_ids, ->(university_ids) { joins(question: { departments: :university }).where(universities: { id: university_ids }).distinct }
  scope :by_year, ->(start_year, end_year) { joins(:question).where(questions: { year: start_year..end_year }).distinct }
  # OR検索
  # scope :by_unit_ids, ->(unit_ids) { joins(question: :questions_units_mediators).where(questions_units_mediators: { unit_id: unit_ids }).distinct }
  # AND検索
  scope :by_unit_ids, lambda { |unit_ids|\
    joins(question: :questions_units_mediators)\
      .group(:id)\
      .where(questions_units_mediators: { unit_id: unit_ids })\
      .having("COUNT(DISTINCT questions_units_mediators.id) = ?", unit_ids.size)\
      .distinct
  }

  scope :by_tag_name_array, lambda { |tag_name_array|
    joins("INNER JOIN taggings ON answers.id = taggings.taggable_id")\
      .joins("INNER JOIN tags ON tags.id = taggings.tag_id")\
      .where(tags: { name: tag_name_array })\
      .distinct
  }
  scope :by_questions, ->(questions) { where(question_id: questions.map(&:id)) }

  # クラスメソッド
  class << self
    # arrayが[]、[1]、[1, 2]、[1, 2, 3]と順序の違いを無視して同じかチェック
    def valid_for_order?(array)
      case array.length
      when 0
        true
      when 1
        %w[1] - array == []
      when 2
        %w[1 2] - array == []
      when 3
        %w[1 2 3] - array == []
      else
        false
      end
    end
  end

  # インスタンスメソッド
  # answer の files の position をセット
  def assign_files_position(file_blob_signed_id_to_position_hash)
    file_blob_signed_id_to_position_hash.each do |key, value|
      positioning_file = files.find { |file| file.blob.signed_id == key }
      positioning_file.position = value
    end
  end

  # answer の files の position をアップデート
  def update_files_position(file_blob_signed_id_to_position_hash)
    file_blob_signed_id_to_position_hash.each do |key, value|
      positioning_file = files.find { |file| file.blob.signed_id == key }
      positioning_file.update(position: value)
    end
  end

  # answer save時のトランザクション
  def save_transaction(positions_array)
    Answer.transaction do
      unless Answer.valid_for_order?(positions_array)
        errors.add(:files_position, I18n.t(".activerecord.errors.models.answer.attributes.file_positions.invalid"))
        raise ActiveRecord::RecordInvalid, self
      end
      save!
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  # answer update時のトランザクション
  def update_transaction(params, positions_array)
    Answer.transaction do
      unless Answer.valid_for_order?(positions_array)
        errors.add(:files_position, I18n.t(".activerecord.errors.models.answer.attributes.file_positions.invalid"))
        raise ActiveRecord::RecordInvalid, self
      end
      update!(params)
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def destroy_tags
    tags.each do |tag|
      tag.destroy if tag.taggings_count == 1
    end
  end

  # タグの合計文字数が100文字であること
  def validate_tags_total_word_count_length
    tags_total_word_count = tag_list.join("").length
    errors.add(:tag_list, :validate_tags_total_word_count_length, count: MAX_TAGS_TOTAL_WORD_COUNT) unless tags_total_word_count <= MAX_TAGS_TOTAL_WORD_COUNT
  end
end
