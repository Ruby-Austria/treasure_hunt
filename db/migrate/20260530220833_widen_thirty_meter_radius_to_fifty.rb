# Bump every Vienna Location currently at 30 m unlock_radius to 50 m.
# GPS readings on most consumer phones in the inner city wobble enough
# that 30 m was rejecting players standing right next to the landmark.
class WidenThirtyMeterRadiusToFifty < ActiveRecord::Migration[8.1]
  def up
    affected = Location.where(city: "Vienna", unlock_radius: 30).update_all(unlock_radius: 50)
    say "Widened unlock_radius 30 → 50 on #{affected} Vienna location(s)."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
