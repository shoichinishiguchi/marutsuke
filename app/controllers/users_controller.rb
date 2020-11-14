# frozen_string_literal: true

class UsersController < UserBase
  skip_before_action :user_login_required,
                     :school_select_required,
                     only: %i[new
                              new_line_form
                              create_by_line_form
                              mypage
                              new_authentication_form_by_email
                              create_user_authentication_by_email
                            ]
  before_action :user_log_out_required,
                only: %i[new
                         new_line_form
                         create_by_line_form
                         new_authentication_form_by_email
                         create_user_authentication_by_email
                        ]
  before_action :new_user_permission_check, only: [:new_line_form]

  def mypage; end

  def change_school
    school = current_user.schools.find(params[:school_id])
    user_log_in(current_user, school)
    flash[:success] = "#{school.name}に切り替えました"
    redirect_to root_path
  end

  def edit
  end

  def update
    if current_user.update(user_params)
      flash[:success] = "更新しました。"
      redirect_to mypage_users_path
    else
      flash[:success] = '更新に失敗しました'
      render :mypage
    end
  end

  def new
    @user = User.new
  end

  def new_authentication_form_by_email
    @user_authentication = UserAuthentication.new
  end

  def create_user_authentication_by_email
  end

  def new_line_form
    new_user_permission_check
    @user = User.new(name: '')
  end

  def create_by_line_form
    @user = User.new(user_params)
    if @user.save
      if current_user_authentication.update(user_id: @user.id)
        user_log_in_without_school(@user)
        flash[:success] = '登録完了しました！校舎に招待コードを送ってください!'
        redirect_to new_school_user_path
      else
        flash[:danger] = 'エラーです。'
        raise 'user_has_many_user_authentication'
      end
    else
      render :new_line_form
    end
  end

  private
  def user_params
    params.require(:user).permit(:image, :name, :name_kana, :email, :birth_day, :school_grade)
  end

  def new_user_permission_check
    if user = current_user_authentication&.user
      user_log_in_without_school(user)
      redirect_to root_path
    end
  end
end
