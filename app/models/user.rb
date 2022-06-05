# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                                  :uuid             not null, primary key
#  access_count_to_reset_password_page :integer          default(0)
#  crypted_password                    :string
#  email                               :string           not null
#  name                                :string           not null
#  remember_me_token                   :string
#  remember_me_token_expires_at        :datetime
#  reset_password_email_sent_at        :datetime
#  reset_password_token                :string
#  reset_password_token_expires_at     :datetime
#  role                                :integer          default("general"), not null
#  salt                                :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_remember_me_token     (remember_me_token)
#  index_users_on_reset_password_token  (reset_password_token)
#
class User < ApplicationRecord
  authenticates_with_sorcery!

  attribute :remember, :boolean, default: -> { false }

  before_create :default_image

  validates :name, presence: true, length: { maximum: 10 }
  validates :role, presence: true
  validates :avatar, content_type: ["image/png", "image/jpeg"]

  validates :password, length: { minimum: 8 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  VALID_PASSWORD_REGEX = /\A(?=.*?[a-z])(?=.*?\d)[a-z\d]+\z/i
  validates :password, format: { with: VALID_PASSWORD_REGEX }, if: -> { new_record? || changes[:crypted_password] }

  with_options on: :password_change do
    validates :password, length: { minimum: 8 }
    validates :password, confirmation: true
    validates :password_confirmation, presence: true
    validates :password, format: { with: VALID_PASSWORD_REGEX }
  end

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  has_one_attached :avatar

  enum role: { general: 0, guest: 1, admin: 2 }, _prefix: true

  private

  def default_image
    return if avatar.attached?

    avatar.attach(io: File.open(Rails.root.join("app/assets/images/blank-profile-picture.png")), filename: "blank-profile-picture.png", content_type: "image/png")
  end
end
