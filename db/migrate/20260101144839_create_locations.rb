class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.decimal :lat, precision: 10, scale: 7, null: false
      t.decimal :long, precision: 10, scale: 7, null: false
      t.string :name, null: false
      t.text :description
      t.text :reasoning
      t.string :country, null: false
      t.string :city, null: false
      t.json :tags, default: []
      t.integer :difficulty, null: false, default: 1

      t.timestamps
    end

    add_index :locations, :country
    add_index :locations, :city
    add_index :locations, :difficulty
    add_index :locations, [ :lat, :long ]
  end
end
