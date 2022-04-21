# frozen_string_literal: true

# == Schema Information
#
# Table name: universities
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_universities_on_name  (name) UNIQUE
#
class University < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :departments, inverse_of: :university, dependent: :destroy
  accepts_nested_attributes_for :departments, reject_if: :all_blank, allow_destroy: true
end
