class CreateCourses < ActiveRecord::Migration[7.1]
  def change
    create_table :courses do |t|
      t.string :title
      t.text :description
      t.decimal :price
      t.integer :review
      t.integer :duration
      t.references :category, null: false, foreign_key: true
      t.string :image
      t.text :about

      t.timestamps
    end
  end
end
