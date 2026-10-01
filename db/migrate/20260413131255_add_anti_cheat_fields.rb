class AddAntiCheatFields < ActiveRecord::Migration[8.1]
  def change
    add_column :adventures, :last_check_lat, :decimal, precision: 10, scale: 6
    add_column :adventures, :last_check_long, :decimal, precision: 10, scale: 6
    add_column :adventures, :last_check_at, :datetime

    add_column :users, :flagged_at, :datetime
    add_column :users, :flag_reason, :string
  end
end
