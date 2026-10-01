class RemoveTagsFromHuntsAndLocations < ActiveRecord::Migration[8.1]
  def change
    remove_column :hunts, :tags, :json
    remove_column :locations, :tags, :json
  end
end
