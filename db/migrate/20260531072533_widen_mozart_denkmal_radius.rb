# Widen Mozart-Denkmal · Burggarten unlock_radius from 50 m to 80 m.
# Burggarten is a large open garden and players approaching from
# either of the two gates were missing the unlock circle by a few
# metres.
class WidenMozartDenkmalRadius < ActiveRecord::Migration[8.1]
  def up
    loc = Location.find_by(name: "Mozart-Denkmal · Burggarten", city: "Vienna")
    return say "Skipping — location not present" unless loc

    old = loc.unlock_radius
    loc.update!(unlock_radius: 80)
    say "Mozart-Denkmal · Burggarten unlock_radius: #{old} m → 80 m."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
