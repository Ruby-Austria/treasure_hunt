class AddStoryFieldsToClues < ActiveRecord::Migration[8.1]
  def change
    add_column :clues, :sequence_number, :integer
    add_column :clues, :riddle, :text # AI-generated riddle
    add_column :clues, :story_bridge, :text # Narrative connection to next clue
    add_column :clues, :bonus_task, :string # e.g., "Jump 5 times" for kids
    add_column :clues, :image_url, :string
    add_column :clues, :proximity_feedback, :boolean, default: true

    add_index :clues, [ :hunt_id, :sequence_number ], unique: true
  end
end
