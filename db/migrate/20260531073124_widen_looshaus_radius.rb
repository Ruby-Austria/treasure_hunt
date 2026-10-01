# Widen Looshaus unlock_radius from 35 m to 80 m. The only active
# hunt stop still below 49 m.
class WidenLooshausRadius < ActiveRecord::Migration[8.1]
  def up
    loc = Location.find_by(name: "Looshaus", city: "Vienna")
    return say "Skipping — Looshaus not present" unless loc

    old = loc.unlock_radius
    loc.update!(unlock_radius: 80)
    say "Looshaus unlock_radius: #{old} m → 80 m."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
