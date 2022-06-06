# frozen_string_literal: true

class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    redirect_if_logged_in
    @user = User.new
  end

  def create
    @user = login(user_sessions_params[:email], user_sessions_params[:password], user_sessions_params[:remember])

    if @user
      redirect_back_or_to root_path, success: t(".success")
    else
      @user = User.new(user_sessions_params)
      flash.now[:danger] = t(".fail")
      render "user_sessions/new"
    end
  end

  def destroy
    logout
    redirect_to root_path, success: t(".success")
  end

  private

  def user_sessions_params
    params.require(:user).permit(:email, :password, :remember)
  end
end
