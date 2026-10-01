# Reshape both Vienna hunts based on playthrough feedback:
#
#   Hunt 1 ("The Hidden City") gets longer (12 → 15 stops):
#     + Schweizertor (Hofburg Innerer Burghof) — Frederick III's AEIOU motto
#     + Donnerbrunnen (Neuer Markt) — Maria Theresia's "obscenity" fight
#     + Mozarthaus (Domgasse 5) — where Figaro was written, behind cathedral
#
#   Hunt 2 ("Vienna Reinvented") gets shorter and inner-Ring (12 → 10 stops):
#     - drop Karl-Marx-Hof  (far-north Red Vienna housing, "not particularly glamorous")
#     - drop Gasometer       (the 8 km capstone to Simmering)
#     - drop Haus Wittgenstein (geometric house, replaced with MAK)
#     + MAK · Stubenring 5   (Europe's first applied-arts museum, 1871) — slots
#                              between KunstHaus and Strauss-Denkmal as the new
#                              stop 3.
#
# Hint policy from v3 preserved: no place name in any hint; player learns
# the actual location only at GPS check-in.
class ReshapeViennaHunts < ActiveRecord::Migration[8.1]
  HIDDEN_CITY = "The Hidden City"
  VIENNA_REINVENTED = "Vienna Reinvented"

  HIDDEN_CITY_ORDER = [
    "Looshaus",
    "Vindobona ruins · Michaelerplatz",
    "Spanische Hofreitschule · Josefsplatz",
    "Schweizertor · Hofburg",                          # NEW
    "Donnerbrunnen · Neuer Markt",                     # NEW
    "Mozart-Denkmal · Burggarten",
    "Theseustempel · Volksgarten",
    "Mölker Bastei · Pasqualatihaus",
    "Freyung · Austria-Brunnen",
    "Maria am Gestade",
    "Ankeruhr · Hoher Markt",
    "Mozarthaus · Domgasse 5",                         # NEW
    "Stock im Eisen",
    "Stephansdom · Türkenkanonenkugel",
    "Postsparkasse"
  ]

  VIENNA_REINVENTED_ORDER = [
    "Hundertwasserhaus",
    "KunstHaus Wien",
    "MAK · Stubenring 5",                              # NEW (replaces Wittgenstein)
    "Johann-Strauss-Denkmal · Stadtpark",
    "Stadtpark · Wienflussportal",
    "Secession",
    "Otto Wagner Stadtbahn-Pavillons · Karlsplatz",
    "MuseumsQuartier",
    "Strudlhofstiege",
    "Müllverbrennungsanlage Spittelau"
    # Dropped: Haus Wittgenstein, Karl-Marx-Hof, Gasometer
  ]

  HUNT_2_DROPPED_LOCATIONS = [
    "Haus Wittgenstein",
    "Karl-Marx-Hof",
    "Gasometer"
  ]

  NEW_CLUES = {
    "Schweizertor · Hofburg" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.20660",
      long:       "16.36546",
      radius:     30,
      difficulty: :challenging,
      title:      "The Five Letters",
      riddle:     "An emperor signed everything with five letters: A · E · I · O · U. Six centuries later, nobody agrees what they meant. The painted gate at the heart of the imperial palace bears them above its arch.",
      hints: [
        "A Renaissance gate, painted in Habsburg red and white, deep inside the imperial palace's inner courtyard.",
        "Five vowels in sequence — the personal motto of Frederick III, decoded a dozen ways and never settled.",
        "Pass through the Michaelertrakt; the gate is on the western wall of the Innerer Burghof, just before the Schatzkammer entrance."
      ]
    },
    "Donnerbrunnen · Neuer Markt" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.20740",
      long:       "16.37032",
      radius:     25,
      difficulty: :challenging,
      title:      "The Empress's Shame",
      riddle:     "Bronze nudes around a fountain. An empress ordered them melted. They survived. The ones you see now are copies — but the nakedness she could not bear is back.",
      hints: [
        "South of the Graben, on a square that once held a flour market — Vienna's original 'new market.'",
        "A central Providentia figure presides over four allegorical rivers: Enns, Traun, Ybbs, and March.",
        "Maria Theresia found the original 18th-century bronzes obscene; the 19th-century replacements are what you see today."
      ]
    },
    "Mozarthaus · Domgasse 5" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.20857",
      long:       "16.37335",
      radius:     25,
      difficulty: :challenging,
      title:      "Figaro's Address",
      riddle:     "A composer wrote his most famous comic opera in three rooms here, then moved out three years later. The window above the bronze plaque is the one he opened to listen to the cathedral bells.",
      hints: [
        "On a narrow alley directly behind the city's main cathedral — Domgasse means 'cathedral street.'",
        "Where Mozart wrote The Marriage of Figaro, 1784–1787, and where he met Haydn for the first time.",
        "Look for the bronze plaque on a townhouse facing south, immediately behind the cathedral apse."
      ]
    },
    "MAK · Stubenring 5" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.20881",
      long:       "16.37956",
      radius:     30,
      difficulty: :challenging,
      title:      "The Applied Arts",
      riddle:     "A museum that refused the academy's hierarchy: chairs, lamps and posters get the same plinth as paintings. Built when 'design' was still a word that didn't quite exist.",
      hints: [
        "On the Ringstrasse where it meets the Stadtpark, at the corner of Stubenring and Weiskirchnerstraße.",
        "Heinrich von Ferstel, 1871. Europe's first museum dedicated to applied arts and craft.",
        "The foundation institution of the Wiener Werkstätte and the design lineage of the Vienna Secession."
      ]
    }
  }

  def up
    drop_hunt_2_clues!
    create_or_update_new_locations!
    reorder_hunt!(HIDDEN_CITY,       HIDDEN_CITY_ORDER)
    reorder_hunt!(VIENNA_REINVENTED, VIENNA_REINVENTED_ORDER)
    say "Hunt 1 → 15 stops; Hunt 2 → 10 stops."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def drop_hunt_2_clues!
    hunt = Hunt.find_by(name: VIENNA_REINVENTED)
    return unless hunt

    HUNT_2_DROPPED_LOCATIONS.each do |loc_name|
      location = Location.find_by(name: loc_name, city: "Vienna")
      next unless location

      clue = hunt.clues.find_by(location: location)
      next unless clue

      clue.destroy!
      say "Dropped #{loc_name} from #{VIENNA_REINVENTED}."
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
