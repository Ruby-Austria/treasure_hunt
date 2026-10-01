class AddLanguageToHunts < ActiveRecord::Migration[8.1]
  def change
    add_column :hunts, :language, :string, default: "en", null: false
  end
end
