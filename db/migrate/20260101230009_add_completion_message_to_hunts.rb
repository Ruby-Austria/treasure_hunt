class AddCompletionMessageToHunts < ActiveRecord::Migration[8.1]
  def change
    add_column :hunts, :completion_message, :text
  end
end
