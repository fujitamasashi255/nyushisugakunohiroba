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

  # ログイン記憶フォームで利用する仮想属性
  attribute :remember, :boolean, default: -> { false }

  # ユーザー作成時にデフォルトのavatarをattachする
  before_create :default_avatar

  validates :name, presence: true, length: { maximum: 10 }
  validates :role, presence: true
  validates \
    :avatar, \
    content_type: ["image/png", "image/jpeg"], \
    size: { less_than: 3.megabytes, message: "サイズは3MB以下にして下さい" }, \
    limit: { max: 1, message: "は1つにして下さい" }

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
  has_many :answers, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :answered_questions, through: :answers, source: :question
  has_many :likes, dependent: :destroy
  has_many :liked_answers, through: :likes, source: :answer

  enum role: { general: 0, guest: 1, admin: 2 }, _default: :general

  # ユーザーの作成した解答のidをvalue、その問題のidをkeyとするhashを作成
  def question_id_to_answer_id_hash
    answers.pluck(:question_id, :id).to_h
  end

  # ユーザーがanswerを作成したか判定
  def own_answer?(answer)
    answers.include?(answer)
  end

  # ユーザーのanswerに対するlikeを取得
  def like_of(answer)
    likes.find_by(answer:)
  end

  # ユーザーがanswerにいいねしたかどうかを判定
  def liked?(answer)
    !!like_of(answer)
  end

  private

  # コールバック
  def default_avatar
    return if avatar.attached?

    avatar.attach(io: File.open(Rails.root.join("app/assets/images/blank-profile-picture.jpg")), filename: "blank-profile-picture.jpg", content_type: "image/png")
  end
end
