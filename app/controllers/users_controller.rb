# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  before_action :set_user, only: %i[show edit update destroy]

  def new
    redirect_if_logged_in
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      auto_login(@user)
      redirect_back_or_to @user, success: t(".success")
    else
      flash.now[:danger] = t(".fail")
      render "users/new"
    end
  end

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to @user, success: t(".success")
    else
      if @user.errors.include?(:avatar)
        # ファイル登録失敗時は、エラーメッセージと共に、元々登録されていたファイルを表示する
        @user.avatar = User.find(params[:id]).avatar.blob
      else
        # ファイル登録成功時は、そのファイルを保存し、フォームに表示する
        change = @user.attachment_changes["avatar"]
        if change.is_a?(ActiveStorage::Attached::Changes::CreateOne)
          change.upload
          change.blob.save
        end
      end
      flash.now[:danger] = t(".fail")
      render "users/edit"
    end
  end

  def destroy
    @user.destroy!
    redirect_to root_path, success: t(".success")
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar)
  end

  def set_user
    @user = User.find(params[:id])
  end
end
