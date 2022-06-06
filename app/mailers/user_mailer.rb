# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def reset_password_email(user)
    @user = User.find(user.id)
    @url  = edit_password_reset_url(@user.reset_password_token)
    mail(to: user.email, subject: "【入試数学の広場】パスワード再設定URL の送付")
  end
end
