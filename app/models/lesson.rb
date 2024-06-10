class Lesson < ApplicationRecord
  belongs_to :course_module
  has_many :comments
  has_many_attached :files

  serialize :google_form_links, JSON

  validates :title, presence: true
  validates :description, presence: true
  validate :valid_google_form_links

  private

  def valid_google_form_links
    return unless google_form_links.is_a?(Array)

    google_form_links.each do |link|
      errors.add(:google_form_links, "Invalid link: #{link}") unless link.is_a?(String)
    end
  end
end
