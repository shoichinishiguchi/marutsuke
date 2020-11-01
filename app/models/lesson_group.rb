# frozen_string_literal: true

# == Schema Information
#
# Table name: lesson_groups
#
#  id                 :bigint           not null, primary key
#  name               :string(255)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  school_building_id :bigint
#
# Indexes
#
#  index_lesson_groups_on_school_building_id  (school_building_id)
#
class LessonGroup < ApplicationRecord
  belongs_to :school_building
  has_many :lesson_group_users
  has_many :users, through: :lesson_group_users
  has_many :lessons
  validates :name, presence: true, length: { maximum: 30 }, uniqueness: { scope: [:school_building_id, :school_year], case_sensitive: false }
  validates :min_school_grade, presence: true
  validate :min_school_grade_validate
  validate :max_school_grade_validate

  scope :for_school_buildings_belonged_to_teacher_and_user,
        lambda { |teacher, user|
          for_school_buildings_belonged_to_teacher(teacher)
            .for_school_buildings_belonged_to_user(user)
        }

  scope :for_school_buildings_belonged_to_teacher, lambda { |teacher|
    where(school_building_id: teacher
            .school_building_teachers.pluck(:school_building_id))
  }

  scope :for_school_buildings_belonged_to_user, lambda { |user|
    where(school_building_id: user.school_building_users.pluck(:school_building_id))
  }

  scope :for_school, lambda { |school|
    joins(:school_building).merge(school.school_buildings)
  }

  def target_school_grade
    if max_school_grade.present?
      "#{ SCHOOL_GRADE_HASH[min_school_grade] } ~ #{ SCHOOL_GRADE_HASH[max_school_grade] }"
    else
      SCHOOL_GRADE_HASH[min_school_grade]
    end
  end

  private


  def min_school_grade_validate
    return if (1..20).include?(min_school_grade) || min_school_grade.nil?

    errors.add(:min_school_grade, 'は不正な値です。')
  end

  def max_school_grade_validate
    return if max_school_grade.nil?

    errors.add(:max_school_grade, 'は対象学年より上の学年にしてください。') unless min_school_grade < max_school_grade
    errors.add(:max_school_grade, 'は不正な値です。') unless (1..19).include?(max_school_grade)
  end

end
