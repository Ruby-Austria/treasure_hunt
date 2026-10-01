# Add four interstitial stops to break up the longest legs in both
# Vienna hunts. Hunt 1 gets Freyung · Austria-Brunnen and Stephansdom's
# Türkenkanonenkugel; Hunt 2 gets Haus Wittgenstein and the Stadtpark
# Wienflussportal. Existing clue sequence_numbers are shifted to make
# room. Coords here are first-pass; user will hand-validate via Google
# Maps later as before.
class AddViennaHuntInterstitialStops < ActiveRecord::Migration[8.1]
  HIDDEN_CITY = "The Hidden City"
  VIENNA_REINVENTED = "Vienna Reinvented"

  # Final 12-stop order for Hunt 1.
  HIDDEN_CITY_ORDER = [
    "Looshaus",
    "Vindobona ruins · Michaelerplatz",
    "Spanische Hofreitschule · Josefsplatz",
    "Mozart-Denkmal · Burggarten",
    "Theseustempel · Volksgarten",
    "Mölker Bastei · Pasqualatihaus",
    "Freyung · Austria-Brunnen",                     # NEW
    "Maria am Gestade",
    "Ankeruhr · Hoher Markt",
    "Stock im Eisen",
    "Stephansdom · Türkenkanonenkugel",              # NEW
    "Postsparkasse"
  ]

  # Final 12-stop order for Hunt 2.
  VIENNA_REINVENTED_ORDER = [
    "Hundertwasserhaus",
    "KunstHaus Wien",
    "Haus Wittgenstein",                             # NEW
    "Johann-Strauss-Denkmal · Stadtpark",
    "Stadtpark · Wienflussportal",                   # NEW
    "Secession",
    "Otto Wagner Stadtbahn-Pavillons · Karlsplatz",
    "MuseumsQuartier",
    "Strudlhofstiege",
    "Müllverbrennungsanlage Spittelau",
    "Karl-Marx-Hof",
    "Gasometer"
  ]

  # New clue definitions: location data + clue copy. Hint policy
  # (v3, established earlier): no place name in any hint; player learns
  # the actual location name only after GPS check-in.
  NEW_CLUES = {
    "Freyung · Austria-Brunnen" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.2117",
      long:       "16.3661",
      radius:     30,
      difficulty: :challenging,
      title:      "The Four Rivers",
      riddle:     "A square named for sanctuary. At its centre, four bronze women pour the empire's rivers — name them and you've named what's been lost.",
      hints: [
        "An inner-city square that owes its name to a medieval right of asylum, granted by Irish-Scottish monks.",
        "Four bronze allegorical women on a fountain plinth: Danube, Vistula, Po, Elbe.",
        "Between Herrengasse and Schottentor, at the foot of the oldest monastery in Vienna."
      ]
    },
    "Stephansdom · Türkenkanonenkugel" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.2086",
      long:       "16.3729",
      radius:     30,
      difficulty: :challenging,
      title:      "The Souvenir",
      riddle:     "A dark sphere is buried high in the cathedral's south wall. It was fired in 1683. Nobody removed it.",
      hints: [
        "Look up — the south buttress of the city's tallest church, just below the eaves.",
        "Iron, smooth, the size of a melon. A small plaque dates it to the year of the second siege.",
        "On the south face of the cathedral whose spire dominates the inner-city skyline."
      ]
    },
    "Haus Wittgenstein" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.2061",
      long:       "16.3937",
      radius:     25,
      difficulty: :challenging,
      title:      "Every Right Angle",
      riddle:     "A philosopher designed his sister a house. He drew every doorknob himself. Every angle is right; no ornament anywhere; the windows are exactly as wide as they need to be.",
      hints: [
        "Built in the 3rd district by a man best known for a book about the limits of language.",
        "Functionalism before the word existed. White walls, no decoration, severe geometry.",
        "On Kundmanngasse, between the Hundertwasserhaus and the Donaukanal — a single severe house among older apartment blocks."
      ]
    },
    "Stadtpark · Wienflussportal" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.2042",
      long:       "16.3795",
      radius:     30,
      difficulty: :challenging,
      title:      "Where the River Goes Down",
      riddle:     "At the edge of the park, an arch covers the place where a river ducks under the city. It will not surface again until it is almost at the Danube.",
      hints: [
        "The southern edge of Vienna's first public park, where a man-made tunnel mouth opens beside the lake.",
        "Friedrich Ohmann and Josef Hackhofer, 1903. A Donauweibchen statue presides over the portal.",
        "A Jugendstil arch on the river-cover, a short walk south of the gilded composer in the same park."
      ]
    }
  }

  def up
    create_or_update_new_locations!
    reorder_hunt!(HIDDEN_CITY,        HIDDEN_CITY_ORDER)
    reorder_hunt!(VIENNA_REINVENTED,  VIENNA_REINVENTED_ORDER)
    say "Added 4 interstitial stops. Hunt 1 → 12 stops, Hunt 2 → 12 stops."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

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
      # Phase 1: offset existing sequence_numbers into negative space so
      # the unique (hunt_id, sequence_number) index doesn't fight us.
      hunt.clues.find_each do |clue|
        clue.update_columns(sequence_number: -(clue.sequence_number || 0).abs - 1000)
      end

      # Phase 2: walk the ordered list. Reuse existing clues if present,
      # otherwise create new ones from NEW_CLUES.
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
