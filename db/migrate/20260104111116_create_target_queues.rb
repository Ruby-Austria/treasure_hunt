class CreateTargetQueues < ActiveRecord::Migration[8.1]
  def change
    create_table :target_queues do |t|
      t.string :city, null: false
      t.string :country, null: false
      t.integer :hunts_to_generate, default: 1
      t.integer :hunts_generated_count, default: 0
      t.integer :priority, default: 0
      t.boolean :processed, default: false
      t.datetime :last_generated_at
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :target_queues, :city
    add_index :target_queues, :country
    add_index :target_queues, [ :city, :country ], unique: true
    add_index :target_queues, :priority
    add_index :target_queues, :processed
  end
end
