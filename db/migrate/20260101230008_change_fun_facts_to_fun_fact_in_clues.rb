class ChangeFunFactsToFunFactInClues < ActiveRecord::Migration[8.1]
  def up
    # Remove the old fun_facts column
    remove_column :clues, :fun_facts, :json

    # Add the new fun_fact column as text
    add_column :clues, :fun_fact, :text
  end

  def down
    # Remove the new fun_fact column
    remove_column :clues, :fun_fact, :text

    # Restore the old fun_facts column
    add_column :clues, :fun_facts, :json, default: [], null: false
  end
end
