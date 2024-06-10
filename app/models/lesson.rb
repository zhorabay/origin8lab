class Lesson < ApplicationRecord
  belongs_to :course_module
  has_many :comments
  has_many_attached :files

  serialize :google_form_links, Array

  validate :valid_google_form_links

  private

  def valid_google_form_links
    google_form_links.each do |link|
      unless link =~ URI::DEFAULT_PARSER.make_regexp
        errors.add(:google_form_links, "#{link} is not a valid URL")
      end
    end
  end
end
