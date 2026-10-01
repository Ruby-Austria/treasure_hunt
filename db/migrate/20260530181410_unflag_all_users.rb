# Clear all flagged_at / flag_reason on users. The teleportation
# detection that set these fields has been removed from
# AntiCheatService — U-Bahn / tram rides between stop clusters
# legitimately exceed the old 50 km/h threshold.
class UnflagAllUsers < ActiveRecord::Migration[8.1]
  def up
    affected = User.where.not(flagged_at: nil).update_all(flagged_at: nil, flag_reason: nil)
    say "Unflagged #{affected} user(s)."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
