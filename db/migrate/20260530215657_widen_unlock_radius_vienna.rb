# Widen MAK · Stubenring 5 unlock_radius to 200 m. The current 30 m
# proved too tight; the museum frontage along the Stubenring is long
# and players approached from the south end were outside the circle.
class WidenUnlockRadiusVienna < ActiveRecord::Migration[8.1]
  def up
    loc = Location.find_by(name: "MAK · Stubenring 5", city: "Vienna")
    return say "Skipping — MAK location not present" unless loc

    old = loc.unlock_radius
    loc.update!(unlock_radius: 200)
    say "MAK · Stubenring 5 unlock_radius: #{old} m → 200 m."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
