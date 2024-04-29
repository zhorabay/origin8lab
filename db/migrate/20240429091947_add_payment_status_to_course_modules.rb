class AddPaymentStatusToCourseModules < ActiveRecord::Migration[7.1]
  def change
    add_column :course_modules, :payment_status, :integer
  end
end
