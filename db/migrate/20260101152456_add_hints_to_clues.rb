class AddHintsToClues < ActiveRecord::Migration[8.1]
  def change
    add_column :clues, :hints, :json, default: [], null: false
  end
end
