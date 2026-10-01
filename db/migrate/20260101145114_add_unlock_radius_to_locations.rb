class AddUnlockRadiusToLocations < ActiveRecord::Migration[8.1]
  def change
    add_column :locations, :unlock_radius, :decimal, precision: 10, scale: 2
  end
end
