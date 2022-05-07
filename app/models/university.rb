# frozen_string_literal: true

# == Schema Information
#
# Table name: universities
#
#  id            :bigint           not null, primary key
#  category      :integer          default(0), not null
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  prefecture_id :bigint
#
# Indexes
#
#  index_universities_on_name  (name) UNIQUE
#
class University < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  validates :name, presence: true, uniqueness: true
  validates :category, presence: true
  validate :different_departments?
  validate :prefecture_present?

  enum category: { national_or_public: 0, private: 1 }, _prefix: true

  has_many :departments, inverse_of: :university, dependent: :destroy
  belongs_to_active_hash :prefecture
  accepts_nested_attributes_for :departments, reject_if: :all_blank, allow_destroy: true

  default_scope { order(:prefecture_id) }

  private

  def different_departments?
    errors.add(:base, "同じ名前の区分を登録することはできません") if departments.map(&:name).uniq.size < departments.size
  end

  def prefecture_present?
    errors.add(:base, "都道府県を登録してください") if prefecture.blank?
  end
end
