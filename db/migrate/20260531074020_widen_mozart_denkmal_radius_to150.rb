# Bump Mozart-Denkmal · Burggarten unlock_radius from 80 m to 150 m.
# Burggarten is large; covering all approaches from either gate plus
# the Albertina side.
class WidenMozartDenkmalRadiusTo150 < ActiveRecord::Migration[8.1]
  def up
    loc = Location.find_by(name: "Mozart-Denkmal · Burggarten", city: "Vienna")
    return say "Skipping — Mozart-Denkmal not present" unless loc

    old = loc.unlock_radius
    loc.update!(unlock_radius: 150)
    say "Mozart-Denkmal · Burggarten unlock_radius: #{old} m → 150 m."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
