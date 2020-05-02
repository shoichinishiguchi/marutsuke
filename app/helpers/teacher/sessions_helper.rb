module Teacher::SessionsHelper

  def teacher_log_in(teacher)
    session[:teacher_id] = teacher.id
  end

  def remember_teacher(teacher)
    teacher.remember
    cookies.permanent.signed[:teacher_id] = teacher.id
    cookies.permanent[:teacher_remember_token] = teacher.teacher_remember_token
  end

  def forget_teacher(teacher)
    teacher.forget
    cookies.delete(:teacher_id)
    cookies.delete(:teacher_remember_token)
  end

  def teacher_log_out
    forget_teacher(current_teacher)
    session.delete(:teacher_id)
    @current_teacher = nil
  end

  def current_teacher
    if teacher_id = session[:teacher_id]
      @current_teacher ||= Teacher.find_by(id: teacher_id)
    elsif teacher_id = cookies.signed[:teacher_id]
      teacher = Teacher.find_by(id: teacher_id)
      if teacher&.authenticated?(cookies[:teacher_remember_token])
        teacher_log_in(teacher)
        @current_teacher = teacher
      end
    end
  end

  def current_school
    current_teacher.school if current_teacher
  end

end
