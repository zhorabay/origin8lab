class AddGoogleFormLinkToLessons < ActiveRecord::Migration[7.1]
  def change
    add_column :lessons, :google_form_link, :string
  end
end
