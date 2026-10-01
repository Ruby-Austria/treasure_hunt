# Apply changes captured during the post-walkthrough coordinate review.
#
# Hunt 1 ("The Hidden City") 21 stops:
#   - 8 coord updates (Schönbrunn ×3, Technisches Museum, Staatsoper,
#     Liechtenstein, Cossacks, Tegetthoff)
#   - swap #5:  Globe Museum → Haus des Meeres
#                 (flak-tower twin of Augarten in Hunt 2; aquarium since 1957)
#   - swap #21: Himmelteich → Jane-Jacobs-Steg
#                 (the bridge across the Seestadt lake itself, not the park
#                  beside it; named for urbanist Jane Jacobs)
#
# Hunt 2 ("Vienna Reinvented") 16 → 15 stops:
#   - 8 coord updates (Hofpavillon Hietzing, Karlskirche, Augarten Flak,
#     Donaukanal Hundertwasser-Promenade, Setagayapark, Hirschstetten,
#     Copa Beach, Riesenrad)
#   - drop: Photo Point Donauufer (thin as a clue)
class ApplyViennaCoordinateWalk < ActiveRecord::Migration[8.1]
  HIDDEN_CITY = "The Hidden City"
  VIENNA_REINVENTED = "Vienna Reinvented"

  HIDDEN_CITY_ORDER = [
    "Schönbrunn · Schloss",
    "Schönbrunn · Gloriette",
    "Schönbrunn · Römische Ruine",
    "Technisches Museum Wien",
    "Haus des Meeres",                                      # NEW (was Globe Museum)
    "Looshaus",
    "Vindobona ruins · Michaelerplatz",
    "Schweizertor · Hofburg",
    "Mozart-Denkmal · Burggarten",
    "Theseustempel · Volksgarten",
    "Mölker Bastei · Pasqualatihaus",
    "Freyung · Austria-Brunnen",
    "Maria am Gestade",
    "Ankeruhr · Hoher Markt",
    "Stock im Eisen",
    "Stephansdom · Türkenkanonenkugel",
    "Wiener Staatsoper",
    "Garten-Palais Liechtenstein",
    "Denkmal der ukrainischen Kosaken · Türkenschanzpark",
    "Tegetthoff-Denkmal · Praterstern",
    "Jane-Jacobs-Steg · Seestadt Aspern"                    # NEW (was Himmelteich)
  ]

  VIENNA_REINVENTED_ORDER = [
    "Hofpavillon Hietzing · Otto Wagner",
    "Karlskirche · Karlsplatz",
    "Secession",
    "Johann-Strauss-Denkmal · Stadtpark",
    "Stadtpark · Wienflussportal",
    "MAK · Stubenring 5",
    "Hundertwasserhaus",
    "KunstHaus Wien",
    "Augarten Flak Tower",
    "Donaukanal Hundertwasser-Promenade",
    "Strudlhofstiege",
    "Setagayapark",
    "Blumengärten Hirschstetten",
    "Copa Beach · Donauinsel",
    "Wiener Riesenrad · Prater"
  ]

  HUNT_1_DROPPED = [
    "Globe Museum · Palais Mollard",
    "Himmelteich · Seestadt Aspern"
  ]

  HUNT_2_DROPPED = [
    "Photo Point Donauufer"
  ]

  NEW_CLUES = {
    "Haus des Meeres" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.197906983167890",
      long:       "16.352820190742708",
      radius:     30,
      difficulty: :challenging,
      title:      "The Other Cube",
      riddle:     "Another five-metre-walled concrete monolith from 1944, this one in the 6th district. It cannot be demolished either. So they filled it with water and sharks.",
      hints: [
        "In Esterházypark, a small public garden in the 6th district off Mariahilfer Straße.",
        "The Leitturm of the Esterházypark flak tower pair, converted into a public aquarium in 1957.",
        "The Haus des Meeres — exterior climbing wall on one side, panoramic café on the roof."
      ]
    },
    "Jane-Jacobs-Steg · Seestadt Aspern" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.226611902125676",
      long:       "16.508166160912182",
      radius:     50,
      difficulty: :challenging,
      title:      "The Urbanist's Bridge",
      riddle:     "A footbridge across an artificial lake in a city that did not exist twenty years ago. Named for an American who fought urban-planning officials her whole life. The buildings around the lake are named after women like her.",
      hints: [
        "In Seestadt Aspern, the 22nd district — built on a former airfield, served by the eastern terminus of the U2.",
        "Jane Jacobs (1916–2006), American-Canadian urbanist whose Death and Life of Great American Cities argued against the modernist demolition of old neighbourhoods.",
        "The Jane-Jacobs-Steg over the Aspern Seestadt lake — a few minutes' walk from the U2 terminus."
      ]
    }
  }

  # Hand-validated coords for existing locations (no clue copy changes).
  COORD_UPDATES = [
    # ─── Hunt 1 ─────────────────────────────────────────────────────────
    { name: "Schönbrunn · Schloss",                                 lat: "48.186082914117410", long: "16.312669886929550", radius: 50 },
    { name: "Schönbrunn · Gloriette",                               lat: "48.178426233511560", long: "16.308735004980670", radius: 50 },
    { name: "Schönbrunn · Römische Ruine",                          lat: "48.180870526874740", long: "16.313357462446646", radius: 50 },
    { name: "Technisches Museum Wien",                              lat: "48.190486834616650", long: "16.317779025488700", radius: 30 },
    { name: "Wiener Staatsoper",                                    lat: "48.203573509707105", long: "16.369149739627240", radius: 50 },
    { name: "Garten-Palais Liechtenstein",                          lat: "48.222692674351040", long: "16.359598797388088", radius: 50 },
    { name: "Denkmal der ukrainischen Kosaken · Türkenschanzpark",  lat: "48.235714101771060", long: "16.334026582046505", radius: 30 },
    { name: "Tegetthoff-Denkmal · Praterstern",                     lat: "48.218106397422970", long: "16.390586968552360", radius: 30 },
    # ─── Hunt 2 ─────────────────────────────────────────────────────────
    { name: "Hofpavillon Hietzing · Otto Wagner",                   lat: "48.187609305487740", long: "16.305851409031202", radius: 50 },
    { name: "Karlskirche · Karlsplatz",                             lat: "48.198516721136110", long: "16.371930454967735", radius: 50 },
    { name: "Augarten Flak Tower",                                  lat: "48.225974673763020", long: "16.373527897388240", radius: 50 },
    { name: "Donaukanal Hundertwasser-Promenade",                   lat: "48.210187450942560", long: "16.395043221439550", radius: 30 },
    { name: "Setagayapark",                                         lat: "48.245332587980556", long: "16.356236955060050", radius: 30 },
    { name: "Blumengärten Hirschstetten",                           lat: "48.240901774763714", long: "16.473980620821244", radius: 30 },
    { name: "Copa Beach · Donauinsel",                              lat: "48.231238430197614", long: "16.410736594046277", radius: 30 },
    { name: "Wiener Riesenrad · Prater",                            lat: "48.216746340122775", long: "16.395913850671768", radius: 50 }
  ]

  def up
    drop_clues_from!(HIDDEN_CITY,        HUNT_1_DROPPED)
    drop_clues_from!(VIENNA_REINVENTED,  HUNT_2_DROPPED)
    apply_coord_updates!
    create_or_update_new_locations!
    reorder_hunt!(HIDDEN_CITY,       HIDDEN_CITY_ORDER)
    reorder_hunt!(VIENNA_REINVENTED, VIENNA_REINVENTED_ORDER)
    say "Hunt 1 → #{HIDDEN_CITY_ORDER.size} stops. Hunt 2 → #{VIENNA_REINVENTED_ORDER.size} stops."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def drop_clues_from!(hunt_name, dropped_location_names)
    hunt = Hunt.find_by(name: hunt_name)
    return say "Skipping #{hunt_name} — hunt not present" unless hunt

    dropped_location_names.each do |loc_name|
      location = Location.find_by(name: loc_name, city: "Vienna")
      next unless location

      clue = hunt.clues.find_by(location: location)
      next unless clue

      clue.destroy!
      say "Dropped #{loc_name} from #{hunt_name}."
    end
  end

  def apply_coord_updates!
    found = 0
    missing = []
    COORD_UPDATES.each do |c|
      loc = Location.find_by(name: c[:name], city: "Vienna")
      if loc
        loc.update!(lat: c[:lat], long: c[:long], unlock_radius: c[:radius])
        found += 1
      else
        missing << c[:name]
      end
    end
    say "Coordinates updated for #{found}/#{COORD_UPDATES.size} existing stops."
    say "Missing: #{missing.inspect}" if missing.any?
  end

  def create_or_update_new_locations!
    NEW_CLUES.each do |loc_name, spec|
      loc = Location.find_or_initialize_by(name: loc_name, city: "Vienna")
      loc.assign_attributes(
        country: "Austria",
        lat: spec[:lat],
        long: spec[:long],
        unlock_radius: spec[:radius],
        difficulty: spec[:difficulty]
      )
      loc.save!
    end
  end

  def reorder_hunt!(hunt_name, ordered_location_names)
    hunt = Hunt.find_by(name: hunt_name)
    return say "Skipping #{hunt_name} — hunt not present" unless hunt

    Clue.transaction do
      hunt.clues.find_each do |clue|
        clue.update_columns(sequence_number: -(clue.sequence_number || 0).abs - 1000)
      end

      ordered_location_names.each_with_index do |loc_name, idx|
        location = Location.find_by(name: loc_name, city: "Vienna")
        unless location
          say "  Couldn't find Location #{loc_name.inspect} — skipping."
          next
        end

        clue = hunt.clues.find_by(location: location) ||
               hunt.clues.build(location: location)

        new_spec = NEW_CLUES[loc_name]
        if new_spec && clue.new_record?
          clue.assign_attributes(
            title:      new_spec[:title],
            riddle:     new_spec[:riddle],
            hints:      new_spec[:hints],
            difficulty: new_spec[:difficulty]
          )
        end

        clue.sequence_number = idx + 1
        clue.save!
      end
    end

    say "Reordered #{hunt_name} (#{ordered_location_names.size} stops)."
  end
end
