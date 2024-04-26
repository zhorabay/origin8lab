class Course < ApplicationRecord
  belongs_to :category
  has_many :course_modules
  has_many :reviews
  has_many :enrollments
  has_many :users, through: :enrollments
end
