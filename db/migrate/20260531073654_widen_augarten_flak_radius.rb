# Widen Augarten Flak Tower unlock_radius from 50 m to 150 m. The
# tower sits in a 50-hectare Baroque park; the actual concrete drum
# is far from the gates and players approaching from any entry need
# a wider circle.
class WidenAugartenFlakRadius < ActiveRecord::Migration[8.1]
  def up
    loc = Location.find_by(name: "Augarten Flak Tower", city: "Vienna")
    return say "Skipping — Augarten Flak Tower not present" unless loc

    old = loc.unlock_radius
    loc.update!(unlock_radius: 150)
    say "Augarten Flak Tower unlock_radius: #{old} m → 150 m."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
