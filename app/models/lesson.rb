class Lesson < ApplicationRecord
  belongs_to :course_module
  has_many :comments
  has_many_attached :files

  validates :google_form_link, url: true, allow_blank: true
end
