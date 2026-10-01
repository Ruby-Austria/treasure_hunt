class AddPartialUniqueIndexForInProgressAdventures < ActiveRecord::Migration[8.1]
  def up
    # First, clean up duplicate in_progress adventures
    # Keep only the most recent one for each user/hunt combination
    execute <<-SQL
      DELETE FROM adventures a1
      USING adventures a2
      WHERE a1.id < a2.id
        AND a1.user_id = a2.user_id
        AND a1.hunt_id = a2.hunt_id
        AND a1.status = 1
        AND a2.status = 1;
    SQL

    # Add partial unique index: only one in_progress adventure per user per hunt
    # PostgreSQL partial index syntax
    add_index :adventures, [ :user_id, :hunt_id ],
              unique: true,
              name: "index_adventures_on_user_id_and_hunt_id_when_in_progress",
              where: "status = 1"
  end

  def down
    remove_index :adventures, name: "index_adventures_on_user_id_and_hunt_id_when_in_progress"
  end
end
