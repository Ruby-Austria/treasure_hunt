class AddFunFactsToClues < ActiveRecord::Migration[8.1]
  def change
    add_column :clues, :fun_facts, :json, default: [], null: false
  end
end
