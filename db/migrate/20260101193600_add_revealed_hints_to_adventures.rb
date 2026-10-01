class AddRevealedHintsToAdventures < ActiveRecord::Migration[8.1]
  def change
    add_column :adventures, :revealed_hints, :json, default: [], null: false
  end
end
