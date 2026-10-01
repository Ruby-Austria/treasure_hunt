# Rebalance both Vienna hunts to 15 stops each.
#
# Hunt 1 ("The Hidden City"):
#   - drop Donnerbrunnen (least player interaction)
#   - drop Mozarthaus (redundant with Mozart-Denkmal in same hunt)
#   + Loos's American Bar (Kärntner Durchgang 10) — Loos bookend
#   + Globe Museum exterior (Palais Mollard, Herrengasse 9) — hidden museum
#
# Hunt 2 ("Vienna Reinvented"):
#   + Karlskirche (Karlsplatz) — touristy iconic Baroque dome
#   + Wiener Riesenrad (Prater) — touristy iconic, becomes the capstone
#     near the Hunt 2 chest (Nordbahnstraße 51 is 300m from the Riesenrad)
#   + Majolikahaus (Linke Wienzeile 40) — Wagner's ceramic-tiled façade
#   + Medaillonhaus (Linke Wienzeile 38) — Wagner's adjacent gilded-Moser façade
#   + Engel-Apotheke (Bognergasse 9) — Olbrich's tiny mosaic pharmacy
#
# Hint policy from v3 preserved: no place name in any hint.
class RebalanceViennaHuntsToFifteen < ActiveRecord::Migration[8.1]
  HIDDEN_CITY = "The Hidden City"
  VIENNA_REINVENTED = "Vienna Reinvented"

  HIDDEN_CITY_ORDER = [
    "Looshaus",
    "Vindobona ruins · Michaelerplatz",
    "Spanische Hofreitschule · Josefsplatz",
    "Schweizertor · Hofburg",
    "Mozart-Denkmal · Burggarten",
    "Theseustempel · Volksgarten",
    "Mölker Bastei · Pasqualatihaus",
    "Globe Museum · Palais Mollard",          # NEW
    "Freyung · Austria-Brunnen",
    "Maria am Gestade",
    "Ankeruhr · Hoher Markt",
    "Stock im Eisen",
    "Loos American Bar · Kärntner Durchgang", # NEW
    "Stephansdom · Türkenkanonenkugel",
    "Postsparkasse"
  ]

  VIENNA_REINVENTED_ORDER = [
    "Hundertwasserhaus",
    "KunstHaus Wien",
    "MAK · Stubenring 5",
    "Johann-Strauss-Denkmal · Stadtpark",
    "Stadtpark · Wienflussportal",
    "Engel-Apotheke · Bognergasse 9",         # NEW
    "Majolikahaus · Linke Wienzeile 40",      # NEW
    "Medaillonhaus · Linke Wienzeile 38",     # NEW
    "Secession",
    "Karlskirche · Karlsplatz",               # NEW
    "Otto Wagner Stadtbahn-Pavillons · Karlsplatz",
    "MuseumsQuartier",
    "Strudlhofstiege",
    "Müllverbrennungsanlage Spittelau",
    "Wiener Riesenrad · Prater"               # NEW (capstone next to chest)
  ]

  HUNT_1_DROPPED = [
    "Donnerbrunnen · Neuer Markt",
    "Mozarthaus · Domgasse 5"
  ]

  NEW_CLUES = {
    "Globe Museum · Palais Mollard" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.21030",
      long:       "16.36560",
      radius:     25,
      difficulty: :challenging,
      title:      "Where the World Is Stored",
      riddle:     "A Baroque palace on a gentlemen's street hides the world's only museum of globes. The oldest inside is from 1536. The strangest weighs nearly half a tonne.",
      hints: [
        "On Herrengasse, the 1st-district street whose name means 'the gentlemen's road.'",
        "Two-hundred-fifty historic celestial and terrestrial globes — Mercator, Coronelli, Blaeu — inside.",
        "The world's only museum exclusively about globes; housed in the Palais Mollard, alongside the Esperanto Museum."
      ]
    },
    "Loos American Bar · Kärntner Durchgang" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.20751",
      long:       "16.37145",
      radius:     20,
      difficulty: :challenging,
      title:      "The Smallest Bar",
      riddle:     "Twenty-four seats in marble, onyx and mirrors. The architect who built it also built a much larger face ten minutes' walk away — the face an emperor refused to look at.",
      hints: [
        "In a narrow shopping arcade between Kärntnerstraße and Stephansplatz.",
        "Adolf Loos, 1908. The architect of stop 1, on a much smaller scale.",
        "Polished marble panels frame the door; the mirrored interior makes a 27 m² room feel three times its size."
      ]
    },
    "Engel-Apotheke · Bognergasse 9" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.21025",
      long:       "16.36766",
      radius:     20,
      difficulty: :challenging,
      title:      "The Mosaic Angels",
      riddle:     "A pharmacy on a narrow alley. Above its door, two angels press gilded wings against a Jugendstil portal. The chemists below still serve aspirin.",
      hints: [
        "On Bognergasse, a tiny alley a few steps from Am Hof in the 1st district.",
        "Oskar Laske, 1902. The two mosaic guardian angels framing the entrance.",
        "An apothecary that has operated continuously since the 17th century; only the façade is from the 20th."
      ]
    },
    "Majolikahaus · Linke Wienzeile 40" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.19810",
      long:       "16.36250",
      radius:     25,
      difficulty: :challenging,
      title:      "The Flowering Façade",
      riddle:     "An apartment block whose entire street face is one continuous bloom — fired ceramic tiles, vines climbing five storeys. The architect insisted the surface should grow, not stop.",
      hints: [
        "On the Linke Wienzeile, five minutes south of the Secession and facing the Naschmarkt.",
        "Otto Wagner, 1898. Built for himself as a speculative investment.",
        "The first apartment façade in Vienna tiled top to bottom — twenty thousand pieces of fired majolica."
      ]
    },
    "Medaillonhaus · Linke Wienzeile 38" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.19820",
      long:       "16.36240",
      radius:     20,
      difficulty: :challenging,
      title:      "The Golden Faces",
      riddle:     "Next door to the flowering façade, gilded female heads stare down from a smooth white wall. The artist who drew them was the same one who designed the gold leaves on the Secession's dome.",
      hints: [
        "Directly adjacent to the previous Wienzeile stop — both buildings by the same architect.",
        "Otto Wagner, 1898–1899. Gilded medallions by Koloman Moser.",
        "Linke Wienzeile 38, the building next door to the flowering one."
      ]
    },
    "Karlskirche · Karlsplatz" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.19810",
      long:       "16.37170",
      radius:     60,
      difficulty: :challenging,
      title:      "The Wound Trumpets",
      riddle:     "Two stone columns rise like wound trumpets beside a green-copper dome. An emperor built this when his city stopped dying of plague — and copied the columns straight from Trajan's victory pillar in Rome.",
      hints: [
        "On a wide square south of the State Opera, between two of the inner Ring's largest fountains.",
        "Johann Bernhard Fischer von Erlach, 1716–1737. Charles VI's vow against the 1713 plague.",
        "A Baroque dome flanked by two spiralling Trajan-style columns covered in reliefs."
      ]
    },
    "Wiener Riesenrad · Prater" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.21610",
      long:       "16.39550",
      radius:     50,
      difficulty: :challenging,
      title:      "The Wheel",
      riddle:     "A great iron wheel turns slowly at the edge of the chestnut wood. Orson Welles rode it once, and said the people below it looked like dots. Most of its original cars are gone; the survivors still circle, sixty-five metres up.",
      hints: [
        "At the western edge of a vast public park, near Praterstern.",
        "1897. Built for the Emperor Franz Joseph's golden jubilee.",
        "The Third Man film. The cuckoo-clock speech. Welles on a slow turn above Vienna."
      ]
    }
  }

  def up
    drop_hunt_1_clues!
    create_or_update_new_locations!
    reorder_hunt!(HIDDEN_CITY,       HIDDEN_CITY_ORDER)
    reorder_hunt!(VIENNA_REINVENTED, VIENNA_REINVENTED_ORDER)
    say "Both hunts now at 15 stops."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def drop_hunt_1_clues!
    hunt = Hunt.find_by(name: HIDDEN_CITY)
    return unless hunt

    HUNT_1_DROPPED.each do |loc_name|
      location = Location.find_by(name: loc_name, city: "Vienna")
      next unless location

      clue = hunt.clues.find_by(location: location)
      next unless clue

      clue.destroy!
      say "Dropped #{loc_name} from #{HIDDEN_CITY}."
    end
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
