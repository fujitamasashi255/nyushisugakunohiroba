# frozen_string_literal: true

# == Schema Information
#
# Table name: universities
#
#  id            :bigint           not null, primary key
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
  validate :different_departments?

  has_many :departments, inverse_of: :university, dependent: :destroy
  belongs_to_active_hash :prefecture
  accepts_nested_attributes_for :departments, reject_if: :all_blank, allow_destroy: true

  default_scope { order(:prefecture_id) }

  private

  def different_departments?
    errors.add(:base, "同じ名前の区分を登録することはできません") if departments.map(&:name).uniq.size < departments.size
  end
end
