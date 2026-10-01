class AddAiFieldsToHunts < ActiveRecord::Migration[8.1]
  def change
    add_column :hunts, :theme, :string
    add_column :hunts, :persona, :string # e.g., 'Noir Detective', 'Happy Scout Dog'
    add_column :hunts, :center_lat, :decimal, precision: 10, scale: 7
    add_column :hunts, :center_lng, :decimal, precision: 10, scale: 7
    add_column :hunts, :total_distance_meters, :integer
    add_column :hunts, :estimated_duration_min, :integer
    add_column :hunts, :ai_generated, :boolean, default: false
    add_column :hunts, :generation_metadata, :jsonb, default: {}

    add_index :hunts, :theme
    add_index :hunts, :ai_generated
    add_index :hunts, [ :center_lat, :center_lng ]
  end
end
