class Lesson < ApplicationRecord
  belongs_to :course_module
  has_many :comments
  has_many_attached :files

  validates :title, presence: true
  validates :description, presence: true
end
