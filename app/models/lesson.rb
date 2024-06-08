class Lesson < ApplicationRecord
  belongs_to :course_module
  has_many :comments
  has_many_attached :files

  attr_accessor :some_attribute, :some_other_attribute

  validate :check_types

  def check_types
    if some_attribute.is_a?(String) && some_other_attribute.is_a?(Integer)
      errors.add(:base, "Type mismatch: #{some_attribute.class} vs #{some_other_attribute.class}")
    end
  end
end
