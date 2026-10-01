# Geographic split + two new tier-1 stops.
#
# Hunt 1 ("The Hidden City") 20 → 16 stops:
#   - Loses to Hunt 2: Schönbrunn ×3, Tech Museum, Haus des Meeres,
#     Looshaus, Vindobona, Schweizertor, Mozart-Denkmal, Theseustempel,
#     Mölker Bastei, Freyung, Liechtenstein, Cossacks (14 stops to H2)
#   - Gains from Hunt 2: Karlskirche, Secession, Strauss-Denkmal,
#     Wienflussportal, MAK, Hundertwasserhaus, Donaukanal graffiti,
#     KunstHaus, Copa Beach (9 stops from H2)
#   - NEW: Belvedere (Prince Eugen's Baroque palace, Klimt's The Kiss
#     lives in Upper Belvedere)
#   - Path: Belvedere → Karlsplatz → inner Ring → Stadtpark →
#           3rd district → Donauinsel → Seestadt
#
# Hunt 2 ("Vienna Reinvented") 13 → 19 stops:
#   - All cross-hunt moves above
#   - NEW: Schmetterlinghaus (Art Nouveau Burggarten butterfly
#     conservatory, paired with Mozart-Denkmal/Theseustempel cluster)
#   - Path: Schönbrunn → west bridge → inner Ring NW arc →
#           9th → 18th → 19th → 2nd → Prater
#
# First-pass coordinates for Belvedere + Schmetterlinghaus — user will
# hand-validate later.
class GeographicSplitViennaHunts < ActiveRecord::Migration[8.1]
  HIDDEN_CITY = "The Hidden City"
  VIENNA_REINVENTED = "Vienna Reinvented"

  HIDDEN_CITY_ORDER = [
    "Schloss Belvedere",                                   # NEW
    "Karlskirche · Karlsplatz",
    "Secession",
    "Wiener Staatsoper",
    "Stock im Eisen",
    "Stephansdom · Türkenkanonenkugel",
    "Ankeruhr · Hoher Markt",
    "Maria am Gestade",
    "MAK · Stubenring 5",
    "Johann-Strauss-Denkmal · Stadtpark",
    "Stadtpark · Wienflussportal",
    "Hundertwasserhaus",
    "Donaukanal Hundertwasser-Promenade",
    "KunstHaus Wien",
    "Copa Beach · Donauinsel",
    "Jane-Jacobs-Steg · Seestadt Aspern"
  ]

  VIENNA_REINVENTED_ORDER = [
    "Schönbrunn · Schloss",
    "Schönbrunn · Römische Ruine",
    "Schönbrunn · Gloriette",
    "Technisches Museum Wien",
    "Haus des Meeres",
    "Theseustempel · Volksgarten",
    "Schmetterlinghaus",                                   # NEW
    "Mozart-Denkmal · Burggarten",
    "Mölker Bastei · Pasqualatihaus",
    "Freyung · Austria-Brunnen",
    "Looshaus",
    "Vindobona ruins · Michaelerplatz",
    "Schweizertor · Hofburg",
    "Strudlhofstiege",
    "Garten-Palais Liechtenstein",
    "Denkmal der ukrainischen Kosaken · Türkenschanzpark",
    "Setagayapark",
    "Augarten Flak Tower",
    "Wiener Riesenrad · Prater"
  ]

  # Locations to move H1 → H2 (their clues' hunt_id will be updated).
  MOVE_TO_H2 = [
    "Schönbrunn · Schloss",
    "Schönbrunn · Gloriette",
    "Schönbrunn · Römische Ruine",
    "Technisches Museum Wien",
    "Haus des Meeres",
    "Looshaus",
    "Vindobona ruins · Michaelerplatz",
    "Schweizertor · Hofburg",
    "Mozart-Denkmal · Burggarten",
    "Theseustempel · Volksgarten",
    "Mölker Bastei · Pasqualatihaus",
    "Freyung · Austria-Brunnen",
    "Garten-Palais Liechtenstein",
    "Denkmal der ukrainischen Kosaken · Türkenschanzpark"
  ]

  # Locations to move H2 → H1.
  MOVE_TO_H1 = [
    "Karlskirche · Karlsplatz",
    "Secession",
    "Johann-Strauss-Denkmal · Stadtpark",
    "Stadtpark · Wienflussportal",
    "MAK · Stubenring 5",
    "Hundertwasserhaus",
    "Donaukanal Hundertwasser-Promenade",
    "KunstHaus Wien",
    "Copa Beach · Donauinsel"
  ]

  NEW_CLUES = {
    "Schloss Belvedere" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.19156",
      long:       "16.38055",
      radius:     60,
      difficulty: :challenging,
      title:      "The Soldier's Palace",
      riddle:     "A soldier-prince built two Baroque palaces and formal gardens to outshine the emperor. The most-reproduced painting in the city hangs in the upper one — but he died two hundred years before it was painted.",
      hints: [
        "South of Schwarzenbergplatz, on the road named after the prince who built it.",
        "Prince Eugen of Savoy, 1717–1723. Architect Johann Lukas von Hildebrandt.",
        "The Upper Belvedere — where Klimt's The Kiss lives. Gardens free; palace ticketed."
      ]
    },
    "Schmetterlinghaus" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.20475",
      long:       "16.36622",
      radius:     25,
      difficulty: :challenging,
      title:      "The Glass Conservatory",
      riddle:     "An Art Nouveau pavilion of iron and glass, set in the imperial back garden. Inside, hundreds of tropical butterflies fly free. The architect built it for palms; the butterflies came almost a hundred years later.",
      hints: [
        "In the small palace garden between the imperial residence and the Ringstraße — a tall glass house at the south end.",
        "Friedrich Ohmann + Ludwig Beermann, 1901. Originally a Palmenhaus; the butterfly conservatory was added in 1998.",
        "The Schmetterlinghaus in the Burggarten — exterior view free, conservatory ticketed."
      ]
    }
  }

  def up
    move_clues!(MOVE_TO_H2, from: HIDDEN_CITY,        to: VIENNA_REINVENTED)
    move_clues!(MOVE_TO_H1, from: VIENNA_REINVENTED,  to: HIDDEN_CITY)
    create_or_update_new_locations!
    reorder_hunt!(HIDDEN_CITY,       HIDDEN_CITY_ORDER)
    reorder_hunt!(VIENNA_REINVENTED, VIENNA_REINVENTED_ORDER)
    say "Hunt 1 → #{HIDDEN_CITY_ORDER.size} stops. Hunt 2 → #{VIENNA_REINVENTED_ORDER.size} stops."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def move_clues!(location_names, from:, to:)
    source_hunt = Hunt.find_by(name: from)
    target_hunt = Hunt.find_by(name: to)
    return say "Skipping moves — missing hunts" unless source_hunt && target_hunt

    location_names.each do |loc_name|
      location = Location.find_by(name: loc_name, city: "Vienna")
      next unless location

      clue = source_hunt.clues.find_by(location: location)
      next unless clue

      # Park sequence in negative space so we don't collide on the
      # target hunt during the update.
      clue.update_columns(
        hunt_id:         target_hunt.id,
        sequence_number: -(clue.sequence_number || 0).abs - 2000
      )
      say "Moved #{loc_name} from #{from} to #{to}."
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
