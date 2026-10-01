class CreateAdventures < ActiveRecord::Migration[8.1]
  def change
    create_table :adventures do |t|
      t.references :user, null: false, foreign_key: true
      t.references :hunt, null: false, foreign_key: true
      t.integer :status, default: 1, null: false
      t.json :clue_ids, default: [], null: false
      t.json :solved_clue_ids, default: [], null: false

      t.timestamps
    end

    add_index :adventures, [ :user_id, :hunt_id ], unique: true, name: "index_adventures_on_user_id_and_hunt_id"
    add_index :adventures, :status
  end
end
