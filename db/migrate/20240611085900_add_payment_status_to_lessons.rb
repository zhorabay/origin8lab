class AddPaymentStatusToLessons < ActiveRecord::Migration[7.1]
  def change
    add_column :lessons, :payment_status, :integer, default: 0, null: false
  end
end
