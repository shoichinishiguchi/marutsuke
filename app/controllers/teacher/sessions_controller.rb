# frozen_string_literal: true

class Teacher::SessionsController < Teacher::Base
  skip_before_action :teacher_login_required
  layout 'layouts/application'
  def new; end

  def create
    teacher = Teacher.find_by(email: params[:session][:email].downcase)
    if teacher&.authenticate(params[:session][:password])
      teacher_log_in(teacher)
      flash[:success] = "#{teacher.name}先生、こんにちは!"
      params[:session][:remember_me] == '1' ? remember_teacher(teacher) : forget_teacher(teacher)
      teacher_redirect_back_or(new_teacher_teacher_url)
    else
      flash.now[:danger] = 'メールアドレスまたはパスワードが間違っています。'
      render :new
    end
  end

  def destroy
    teacher_log_out if current_teacher
    flash[:danger] = 'ログアウトしました。'
    redirect_to teacher_login_path
  end
end
