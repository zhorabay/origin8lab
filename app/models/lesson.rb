class Lesson < ApplicationRecord
  belongs_to :course_module
  has_many :comments
  has_one_attached :video
end
