# Re-shuffle Hunt 2 stop order for shorter total walk.
#
# Changes:
#   - Inner Ring path: Haus des Meeres → Mozart-Denkmal → Schmetterlinghaus →
#     Schweizertor → Vindobona → Looshaus → Freyung → Mölker Bastei →
#     Theseustempel (NN-greedy local optimum, ~4.4 km vs the previous ~5.4 km
#     inner-Ring portion).
#   - Tail: Liechtenstein → Cossacks → Setagaya → Augarten → Riesenrad
#     (avoids the NN trap of zig-zagging back to Cossacks from Augarten).
#
# Net saving: ~1.8 km (20.3 km → 18.5 km).
# Hunt 1 ("The Hidden City") order already optimal — left untouched.
class ReorderHunt2ForOptimalGeography < ActiveRecord::Migration[8.1]
  VIENNA_REINVENTED = "Vienna Reinvented"

  VIENNA_REINVENTED_ORDER = [
    "Schönbrunn · Schloss",
    "Schönbrunn · Römische Ruine",
    "Schönbrunn · Gloriette",
    "Technisches Museum Wien",
    "Haus des Meeres",
    "Mozart-Denkmal · Burggarten",
    "Schmetterlinghaus",
    "Schweizertor · Hofburg",
    "Vindobona ruins · Michaelerplatz",
    "Looshaus",
    "Freyung · Austria-Brunnen",
    "Mölker Bastei · Pasqualatihaus",
    "Theseustempel · Volksgarten",
    "Strudlhofstiege",
    "Garten-Palais Liechtenstein",
    "Denkmal der ukrainischen Kosaken · Türkenschanzpark",
    "Setagayapark",
    "Augarten Flak Tower",
    "Wiener Riesenrad · Prater"
  ]

  def up
    reorder_hunt!(VIENNA_REINVENTED, VIENNA_REINVENTED_ORDER)
    say "Reordered #{VIENNA_REINVENTED} (#{VIENNA_REINVENTED_ORDER.size} stops)."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

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
  end
end
