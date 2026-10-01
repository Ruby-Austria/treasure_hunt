# Hand-validated coords for the two new tier-1 stops.
class ValidateBelvedereAndSchmetterlinghausCoords < ActiveRecord::Migration[8.1]
  CORRECTIONS = [
    { name: "Schloss Belvedere",  lat: "48.191638784529450", long: "16.380884918040596", radius: 50 },
    { name: "Schmetterlinghaus",  lat: "48.205669004893934", long: "16.366289509031976", radius: 30 }
  ]

  def up
    CORRECTIONS.each do |c|
      loc = Location.find_by(name: c[:name], city: "Vienna")
      if loc
        loc.update!(lat: c[:lat], long: c[:long], unlock_radius: c[:radius])
        say "Updated #{c[:name]}."
      else
        say "Missing: #{c[:name].inspect}"
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
