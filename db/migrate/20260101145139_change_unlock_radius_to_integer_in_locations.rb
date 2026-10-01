class ChangeUnlockRadiusToIntegerInLocations < ActiveRecord::Migration[8.1]
  def change
    change_column :locations, :unlock_radius, :integer
  end
end
