class AddProbabilisticFieldsToLocations < ActiveRecord::Migration[8.1]
  def change
    add_column :locations, :confidence_score, :decimal, precision: 3, scale: 2, default: 0.5
    add_column :locations, :verification_state, :integer, default: 0 # 0=ai_generated, 1=auto_verified, 2=human_verified
    add_column :locations, :usage_count, :integer, default: 0
    add_column :locations, :avg_player_lat, :decimal, precision: 10, scale: 7
    add_column :locations, :avg_player_lng, :decimal, precision: 10, scale: 7
    add_column :locations, :google_place_id, :string
    add_column :locations, :metadata, :jsonb, default: {}

    add_index :locations, :verification_state
    add_index :locations, :confidence_score
    add_index :locations, :google_place_id, unique: true, where: "google_place_id IS NOT NULL"
  end
end
