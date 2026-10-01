# Apply changes captured during the post-expansion walkthrough.
#
# Hunt 1 ("The Hidden City") 22 → 21 stops:
#   drop: Loos American Bar · Kärntner Durchgang
#   drop: Stephansdom · Wiener Elle
#   move-in: Technisches Museum Wien (slot between Schönbrunn cluster
#            and Looshaus — geographic bridge from 13th/14th out to
#            the inner Ring rather than the original direct U-Bahn jump)
#
# Hunt 2 ("Vienna Reinvented") 18 → 16 stops:
#   drop: Nußdorfer Schleuse · Otto Wagner
#   move-out: Technisches Museum Wien → Hunt 1
#
# Riddle/hint copy for Technisches Museum unchanged for now; user may
# rewrite later to lean Hidden-City theme. Coordinates also unchanged
# pending the next hand-validation pass.
class AdjustViennaHuntsFromWalkthrough < ActiveRecord::Migration[8.1]
  HIDDEN_CITY = "The Hidden City"
  VIENNA_REINVENTED = "Vienna Reinvented"

  HIDDEN_CITY_ORDER = [
    "Schönbrunn · Schloss",
    "Schönbrunn · Gloriette",
    "Schönbrunn · Römische Ruine",
    "Technisches Museum Wien",                              # MOVED from Hunt 2
    "Looshaus",
    "Vindobona ruins · Michaelerplatz",
    "Schweizertor · Hofburg",
    "Mozart-Denkmal · Burggarten",
    "Theseustempel · Volksgarten",
    "Mölker Bastei · Pasqualatihaus",
    "Globe Museum · Palais Mollard",
    "Freyung · Austria-Brunnen",
    "Maria am Gestade",
    "Ankeruhr · Hoher Markt",
    "Stock im Eisen",
    "Stephansdom · Türkenkanonenkugel",
    "Wiener Staatsoper",
    "Garten-Palais Liechtenstein",
    "Denkmal der ukrainischen Kosaken · Türkenschanzpark",
    "Tegetthoff-Denkmal · Praterstern",
    "Himmelteich · Seestadt Aspern"
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
    "Photo Point Donauufer",
    "Wiener Riesenrad · Prater"
  ]

  HUNT_1_DROPPED = [
    "Loos American Bar · Kärntner Durchgang",
    "Stephansdom · Wiener Elle"
  ]

  HUNT_2_DROPPED = [
    "Nußdorfer Schleuse · Otto Wagner"
  ]

  # Cross-hunt move: clue belongs_to :hunt, so we shift Clue.hunt_id
  # rather than destroy + recreate (preserves the existing title,
  # riddle and hints copy for Technisches Museum).
  MOVE_TECHNISCHES_MUSEUM_TO_HIDDEN_CITY = "Technisches Museum Wien"

  def up
    drop_clues_from!(HIDDEN_CITY,        HUNT_1_DROPPED)
    drop_clues_from!(VIENNA_REINVENTED,  HUNT_2_DROPPED)
    move_technisches_museum!
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

  def move_technisches_museum!
    source_hunt = Hunt.find_by(name: VIENNA_REINVENTED)
    target_hunt = Hunt.find_by(name: HIDDEN_CITY)
    location    = Location.find_by(name: MOVE_TECHNISCHES_MUSEUM_TO_HIDDEN_CITY, city: "Vienna")
    return say "Skipping move — missing prerequisites" unless source_hunt && target_hunt && location

    clue = source_hunt.clues.find_by(location: location)
    return say "Skipping move — Technisches Museum clue not in #{VIENNA_REINVENTED}" unless clue

    # Park the sequence number in negative space first so we don't
    # collide with anything on the target hunt during the update.
    clue.update_columns(
      hunt_id:         target_hunt.id,
      sequence_number: -(clue.sequence_number || 0).abs - 2000
    )
    say "Moved #{MOVE_TECHNISCHES_MUSEUM_TO_HIDDEN_CITY} from #{VIENNA_REINVENTED} to #{HIDDEN_CITY}."
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

        clue = hunt.clues.find_by(location: location)
        unless clue
          say "  No clue in #{hunt_name} for #{loc_name.inspect} — skipping."
          next
        end

        clue.update_columns(sequence_number: idx + 1)
      end
    end

    say "Reordered #{hunt_name} (#{ordered_location_names.size} stops)."
  end
end
