# Apply hand-validated lat/long/radius for all 20 Vienna hunt locations.
# Coords pasted from Google Maps after walking each stop; radii hand-tuned
# per landmark size (tighter for monuments, wider for sprawling buildings).
class CorrectViennaCoordinates < ActiveRecord::Migration[8.1]
  CORRECTIONS = [
    # Hunt 1 — "The Hidden City"
    { name: "Looshaus",                                   lat: "48.208428521988", long: "16.366731531671", radius: 35 },
    { name: "Vindobona ruins · Michaelerplatz",           lat: "48.207961047832", long: "16.366539471817", radius: 30 },
    { name: "Ankeruhr · Hoher Markt",                     lat: "48.211086112441", long: "16.373409912730", radius: 30 },
    { name: "Maria am Gestade",                           lat: "48.213026157433", long: "16.370004955059", radius: 30 },
    { name: "Mölker Bastei · Pasqualatihaus",             lat: "48.212509960095", long: "16.362369941565", radius: 50 },
    { name: "Postsparkasse",                              lat: "48.210047367298", long: "16.380737045570", radius: 50 },
    { name: "Mozart-Denkmal · Burggarten",                lat: "48.204488257665", long: "16.365908685654", radius: 30 },
    { name: "Spanische Hofreitschule · Josefsplatz",      lat: "48.207702736458", long: "16.366206347931", radius: 30 },
    { name: "Theseustempel · Volksgarten",                lat: "48.208389541820", long: "16.361731756406", radius: 30 },
    { name: "Stock im Eisen",                             lat: "48.208440119977", long: "16.371907282045", radius: 30 },

    # Hunt 2 — "Vienna Reinvented"
    { name: "Hundertwasserhaus",                          lat: "48.207385156678", long: "16.394307909952", radius: 30 },
    { name: "KunstHaus Wien",                             lat: "48.211188510454", long: "16.393448212730", radius: 30 },
    { name: "Secession",                                  lat: "48.200525743013", long: "16.365770548830", radius: 50 },
    { name: "Otto Wagner Stadtbahn-Pavillons · Karlsplatz", lat: "48.200302910868", long: "16.370318245719", radius: 30 },
    { name: "MuseumsQuartier",                            lat: "48.202778510429", long: "16.359206456818", radius: 60 },
    { name: "Karl-Marx-Hof",                              lat: "48.246465234659", long: "16.362694140897", radius: 30 },
    { name: "Gasometer",                                  lat: "48.185067806334", long: "16.420142795338", radius: 30 },
    { name: "Müllverbrennungsanlage Spittelau",           lat: "48.234555129886", long: "16.359313300206", radius: 80 },
    { name: "Strudlhofstiege",                            lat: "48.222281939488", long: "16.357782583895", radius: 30 },
    { name: "Johann-Strauss-Denkmal · Stadtpark",         lat: "48.203913055816", long: "16.379130326134", radius: 30 }
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

    say "Coordinates corrected for #{found}/#{CORRECTIONS.size} locations."
    say "Missing: #{missing.inspect}" if missing.any?
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
