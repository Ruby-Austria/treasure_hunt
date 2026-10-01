class RemoveLocationsFromHunts < ActiveRecord::Migration[8.1]
  def change
    remove_column :hunts, :locations, :json, default: [], null: false
  end
end
