# Apply hand-validated lat/long/radius for the four new interstitial
# stops introduced in 20260528094009. Coords pasted from Google Maps
# after walking each stop in the same review pass that produced
# 20260528092127.
class CorrectViennaInterstitialCoordinates < ActiveRecord::Migration[8.1]
  CORRECTIONS = [
    { name: "Freyung · Austria-Brunnen",                lat: "48.211679591838", long: "16.365701621213", radius: 30 },
    { name: "Stephansdom · Türkenkanonenkugel",         lat: "48.208453834276", long: "16.373484244247", radius: 80 },
    { name: "Haus Wittgenstein",                        lat: "48.203332702929", long: "16.394310434563", radius: 30 },
    { name: "Stadtpark · Wienflussportal",              lat: "48.202794287498", long: "16.378755482045", radius: 30 }
  ]

  def up
    found = 0
    missing = []

    CORRECTIONS.each do |c|
      loc = Location.find_by(name: c[:name], city: "Vienna")
      if loc
        loc.update!(lat: c[:lat], long: c[:long], unlock_radius: c[:radius])
        found += 1
      else
        missing << c[:name]
      end
    end

    say "Coordinates corrected for #{found}/#{CORRECTIONS.size} interstitial stops."
    say "Missing: #{missing.inspect}" if missing.any?
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
