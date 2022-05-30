# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id               :uuid             not null, primary key
#  crypted_password :string
#  email            :string           default(""), not null
#  name             :string           not null
#  role             :integer          not null
#  salt             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :name, presence: true, length: { maximum: 20 }
  validates :role, presence: true

  has_one_attached :avatar

  enum role: { general: 0, guest: 1, admin: 2 }, _prefix: true
end
