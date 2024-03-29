class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def edit
    @user = current_user
  end

  def create
    @user = User.new(user_params)
    if @user.save?
      session[:user_id] = @user.id
      redirect_to home_path
  end

  def update
    @user = current_user
  end

  private 

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :band_id, :role, :password, :password_confirmation)
end
