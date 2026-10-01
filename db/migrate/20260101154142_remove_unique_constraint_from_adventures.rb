class RemoveUniqueConstraintFromAdventures < ActiveRecord::Migration[8.1]
  def change
    remove_index :adventures, name: "index_adventures_on_user_id_and_hunt_id"
  end
end
