# frozen_string_literal: true

class Teacher::LessonsController < Teacher::Base
  def index
    @lessons = current_school.lessons
  end

  def show
    @lesson = current_school.lessons.find(params[:id])
  end

  def new
    @lesson = Lesson.new
  end

  def create
    @lesson = current_school.lessons.new(lesson_params)
    if @lesson.save
      flash[:success] = "#{@lesson.name}を作成しました。"
      redirect_to new_teacher_lesson_path
    else
      render :new
    end
  end

  private

  def lesson_params
    params.require(:lesson).permit(
      :name, :teacher_id, :start_at_date, :start_at_hour,
      :start_at_min, :end_at_date, :end_at_hour, :end_at_min
    )
  end
end
