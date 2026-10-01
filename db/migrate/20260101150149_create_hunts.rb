class CreateHunts < ActiveRecord::Migration[8.1]
  def change
    create_table :hunts do |t|
      t.string :name, null: false
      t.text :description
      t.json :locations, default: []
      t.json :tags, default: []
      t.integer :status, default: 1, null: false
      t.integer :difficulty, default: 1, null: false
      t.integer :hunt_type, null: false
      t.decimal :price, precision: 10, scale: 2, default: 0.0, null: false

      t.timestamps
    end

    add_index :hunts, :status
    add_index :hunts, :difficulty
    add_index :hunts, :hunt_type
  end
end
