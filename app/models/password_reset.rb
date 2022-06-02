# frozen_string_literal: true

class PasswordReset
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
