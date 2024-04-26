class AddDetailsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :surname, :string
    add_column :users, :birthdate, :date
    add_column :users, :nationality, :string
    add_column :users, :gender, :string
    add_column :users, :whatsapp, :string
  end
end
