class CourseModule < ApplicationRecord
  belongs_to :course
  has_many :lessons

  enum payment_status: { unpaid: 0, paid: 1 }

  before_create :set_initial_payment_status

  private

  def set_initial_payment_status
    self.payment_status = :unpaid unless payment_status.present?
  end
end
