class AddTreasureFieldsToHunts < ActiveRecord::Migration[8.1]
  def change
    add_column :hunts, :treasure_location, :text
    add_column :hunts, :treasure_access_code, :string
    add_column :hunts, :treasure_hint, :text
    add_column :hunts, :treasure_claimed_at, :datetime
    add_column :hunts, :treasure_claimed_by, :string
  end
end
