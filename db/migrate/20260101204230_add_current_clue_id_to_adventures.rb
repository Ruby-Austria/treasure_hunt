class AddCurrentClueIdToAdventures < ActiveRecord::Migration[8.1]
  def change
    add_column :adventures, :current_clue_id, :integer
    add_foreign_key :adventures, :clues, column: :current_clue_id
    add_index :adventures, :current_clue_id
  end
end
