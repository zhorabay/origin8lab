class Lesson < ApplicationRecord
  belongs_to :course_module
  has_many :comments
  has_many_attached :files

  serialize :google_form_links, JSON

  validates :title, presence: true
  validates :description, presence: true

  enum payment_status: { unpaid: 0, paid: 1 }
end
