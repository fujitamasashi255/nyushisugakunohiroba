# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  role       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 20 }
  validates :role, presence: true

  has_one_attached :avatar

  enum role: { general: 0, guest: 1, admin: 2 }, _prefix: true
end
