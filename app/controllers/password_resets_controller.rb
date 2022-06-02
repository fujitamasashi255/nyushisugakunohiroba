# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  # skip_before_action :require_login
  before_action :authenticate_token_and_fetch_user, only: %i[edit update]

  def new
    @password_reset = PasswordReset.new
  end

  def create
    @password_reset = PasswordReset.new(password_reset_params)
    if @password_reset.valid?
      @user = User.find_by(email: password_reset_params[:email])
      @user&.deliver_reset_password_instructions!
      redirect_to login_path, success: t(".success")
    else
      flash.now[:danger] = t(".fail")
      render "password_resets/new"
    end
  end

  def edit; end

  def update
    @user.password_confirmation = user_params[:password_confirmation]
    # パスワードがblankのときはバリデーションを手動で行う
    if user_params[:password].blank?
      @user.password = user_params[:password]
      @user.valid?(:password_change)
      flash.now[:danger] = t(".fail")
      render "password_resets/edit"
    elsif @user.change_password(user_params[:password])
      redirect_to login_path, success: t(".success")
    else
      flash.now[:danger] = t(".fail")
      render "password_resets/edit"
    end
  end

  private

  def password_reset_params
    params.require(:password_reset).permit(:email)
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def authenticate_token_and_fetch_user
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    not_authenticated and return if @user.blank?
  end
end
