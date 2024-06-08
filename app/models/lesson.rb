class Lesson < ApplicationRecord
  belongs_to :course_module
  has_many :comments
  has_many_attached :files
end
