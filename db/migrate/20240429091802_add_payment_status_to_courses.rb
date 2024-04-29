class AddPaymentStatusToCourses < ActiveRecord::Migration[7.1]
  def change
    add_column :courses, :payment_status, :integer
  end
end
