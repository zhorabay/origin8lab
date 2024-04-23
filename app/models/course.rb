class Course < ApplicationRecord
  belongs_to :category
  has_many :course_modules
  has_many :reviews
end
