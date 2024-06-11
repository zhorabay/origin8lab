class AddGoogleFormLinksToLessons < ActiveRecord::Migration[7.1]
  def change
    add_column :lessons, :google_form_links, :text
  end
end
