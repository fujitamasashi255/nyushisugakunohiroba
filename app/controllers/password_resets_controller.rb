# frozen_string_literal: true

# app/controllers/password_resets_controller.rb
class PasswordResetsController < ApplicationController
  # skip_before_action :require_login

  def new; end

  def create
    @user = User.find_by(email: password_reset_params[:email])
    @user&.deliver_reset_password_instructions!
    redirect_to root_path, success: t(".success")
  end

  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    return if @user.present?

    not_authenticated
  end

  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end

    @user.password_confirmation = user_params[:password_confirmation]

    if @user.change_password(user_params[:password])

      redirect_to root_path, success: t(".success")
    else
      render "password_resets/edit", danger: t(".fail")
    end
  end

  private

  def password_reset_params
    params.require(:password_reset).permit(:email)
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
