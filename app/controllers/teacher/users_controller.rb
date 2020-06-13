# frozen_string_literal: true

class Teacher::UsersController < Teacher::Base
  def index
    @users = current_school.users
  end

  def new
    @user = User.new
  end

  def create
    @user = current_school.users.new(user_params)
    @user.email = nil if @user.email == ''
    if @user.save
      flash[:success] = "#{@user.name}を作成しました"
      redirect_to new_teacher_user_path
    else
      render :new
    end
  end

  def show
    @user = current_school.users.find(params[:id]).decorate
  end

  def edit
    @user = current_school.users.find(params[:id])
  end

  def update
    @user = current_school.users.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "#{@user.name}の情報を更新しました"
      redirect_to edit_teacher_user_path(@user)
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :login_id,
      :start_at_date,
      :start_at_hour,
      :start_at_min,
      :end_at_date,
      :end_at_hour,
      :end_at_min,
      :password,
      :password_confirmation
    )
  end
end
