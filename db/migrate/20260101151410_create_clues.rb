class CreateClues < ActiveRecord::Migration[8.1]
  def change
    create_table :clues do |t|
      t.references :hunt, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.text :description
      t.integer :difficulty, default: 1, null: false
      t.text :reasoning

      t.timestamps
    end

    add_index :clues, [ :hunt_id, :location_id ], unique: true
    add_index :clues, :difficulty
  end
end
