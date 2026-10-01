class AddHintsUsedToAdventures < ActiveRecord::Migration[8.1]
  def change
    add_column :adventures, :hints_used, :integer, default: 0, null: false
  end
end
