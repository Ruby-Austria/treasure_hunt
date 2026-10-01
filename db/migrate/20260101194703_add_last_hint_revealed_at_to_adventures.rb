class AddLastHintRevealedAtToAdventures < ActiveRecord::Migration[8.1]
  def change
    add_column :adventures, :last_hint_revealed_at, :datetime
  end
end
