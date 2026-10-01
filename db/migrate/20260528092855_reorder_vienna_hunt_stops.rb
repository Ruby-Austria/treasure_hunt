# Reorder both Vienna hunts based on the post-coord-validation walking
# analysis:
#
# - Hunt 1 ("The Hidden City") tightens from 5.67 km / 1.4 km max-leg to
#   ~3.8 km / ~700 m max-leg by moving Postsparkasse to the end and
#   visiting the Hofburg cluster (Hofreitschule, Mozart-Denkmal,
#   Theseustempel) before the Mölker Bastei detour.
#
# - Hunt 2 ("Vienna Reinvented") drops from 27.98 km to ~21 km by
#   eliminating the 8 km Karl-Marx-Hof → Gasometer diagonal and the
#   7 km Gasometer → Spittelau back-track. The new order moves
#   geographically NE → W → N → far-SE, with the Gasometer U-Bahn ride
#   as the deliberate capstone.
#
# Idempotent. Clue.hunt_id+sequence_number has a unique index, so we
# offset all rows to negative space first then assign the final order.
class ReorderViennaHuntStops < ActiveRecord::Migration[8.1]
  HIDDEN_CITY_ORDER = [
    "Looshaus",
    "Vindobona ruins · Michaelerplatz",
    "Spanische Hofreitschule · Josefsplatz",
    "Mozart-Denkmal · Burggarten",
    "Theseustempel · Volksgarten",
    "Mölker Bastei · Pasqualatihaus",
    "Maria am Gestade",
    "Ankeruhr · Hoher Markt",
    "Stock im Eisen",
    "Postsparkasse"
  ]

  VIENNA_REINVENTED_ORDER = [
    "Hundertwasserhaus",
    "KunstHaus Wien",
    "Johann-Strauss-Denkmal · Stadtpark",
    "Secession",
    "Otto Wagner Stadtbahn-Pavillons · Karlsplatz",
    "MuseumsQuartier",
    "Strudlhofstiege",
    "Müllverbrennungsanlage Spittelau",
    "Karl-Marx-Hof",
    "Gasometer"
  ]

  def up
    reorder!("The Hidden City",   HIDDEN_CITY_ORDER)
    reorder!("Vienna Reinvented", VIENNA_REINVENTED_ORDER)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def reorder!(hunt_name, ordered_location_names)
    hunt = Hunt.find_by(name: hunt_name)
    return say "Skipping #{hunt_name} — hunt not present" unless hunt

    Clue.transaction do
      # Phase 1: offset existing sequence_numbers into negative space so
      # the unique (hunt_id, sequence_number) index doesn't fight us.
      hunt.clues.find_each do |clue|
        clue.update_columns(sequence_number: -(clue.sequence_number || 0))
      end

      # Phase 2: assign final sequence_number based on the ordered list.
      ordered_location_names.each_with_index do |loc_name, idx|
        clue = hunt.clues.joins(:location).find_by(locations: { name: loc_name })
        if clue
          clue.update_columns(sequence_number: idx + 1)
        else
          say "Couldn't find clue in #{hunt_name} for location #{loc_name.inspect}"
        end
      end
    end

    say "Reordered #{hunt_name}."
  end
end
