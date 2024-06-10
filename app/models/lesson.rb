class Lesson < ApplicationRecord
  belongs_to :course_module
  has_many :comments
  has_many_attached :files

  validates :google_form_link, format: { with: URI::DEFAULT_PARSER.make_regexp, message: 'must be a valid URL' }, allow_blank: true
end
