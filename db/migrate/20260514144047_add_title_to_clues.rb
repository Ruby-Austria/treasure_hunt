class AddTitleToClues < ActiveRecord::Migration[8.1]
  def change
    add_column :clues, :title, :string
  end
end
