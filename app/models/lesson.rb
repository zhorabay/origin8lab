class Lesson < ApplicationRecord
  belongs_to :course_module
  has_many :comments
  has_many_attached :files

  validates :title, presence: true
  validates :description, presence: true
  validate :validate_google_form_links_format

  def validate_google_form_links_format
    errors.add(:google_form_links, 'must be an array') unless google_form_links.is_a?(Array)
  end
end
