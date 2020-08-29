# frozen_string_literal: true

class User < ApplicationRecord
  attr_accessor :user_remember_token,
                :start_at_date, :start_at_hour, :start_at_min,
                :end_at_date, :end_at_hour, :end_at_min
  before_save { email&.downcase! }
  before_save { start_at_set }
  before_save { end_at_set }
  validates :name, presence: true, length: { maximum: 12 }
  validates :email, presence: true,
                    format: { with: VALIDATE_FORMAT_OF_EMAIL },
                    length: { maximum: 50 },
                    uniqueness: { case_sensitive: false },
                    allow_blank: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  has_secure_password

  has_many :answers
  has_many :question_statuses
  has_many :questions, through: :question_statuses
  has_many :school_building_users
  has_many :school_buildings, through: :school_building_users
  has_many :school_users
  has_many :schools, through: :school_users
  has_many :lesson_group_users
  has_many :lesson_groups, through: :lesson_group_users
  accepts_nested_attributes_for :school_building_users, allow_destroy: true

  paginates_per 20

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.user_remember_token = self.class.new_token
    update_attribute(:remember_digest, self.class.digest(user_remember_token))
  end

  def authenticated?(user_remember_token)
    return false if remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password?(user_remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def main_school_building(school)
    school.school_buildings.joins(:school_building_users).merge(SchoolBuildingUser.where(main: true, user_id: id)).first
  end

  def main_and_sub_school_buildings_names_in(school)
    "#{main_school_building_name_in(school)}(所属校), #{sub_school_buildings_name_in(school)}"
  end


  private

  def main_school_building_name_in(school)
    school.school_buildings.joins(:school_building_users).merge(SchoolBuildingUser.where(main: true, user_id: id)).first.name
  end

  def sub_school_buildings_name_in(school)
    sub_school_buildings = school_buildings.where.not(id: main_school_building(school).id)
    sub_school_buildings.where(school_id: school.id).map(&:name).join(',')
  end

  def start_at_set
    if start_at_date.present? && start_at_hour.present? && start_at_min.present?
      self.start_at = Time.zone.parse("#{start_at_date} #{start_at_hour}:#{start_at_min}:00")
    end
  end

  def end_at_set
    if end_at_date.present? && end_at_hour.present? && end_at_min.present?
      self.end_at = Time.zone.parse("#{end_at_date} #{end_at_hour}:#{end_at_min}:00")
    end
  end
end
