# Drop three more stops captured after the coordinate walk.
#
# Hunt 1 ("The Hidden City") 21 → 20 stops:
#   drop: Tegetthoff-Denkmal · Praterstern (#20)
#         Jane-Jacobs-Steg becomes the final stop directly after the
#         Cossacks monument.
#
# Hunt 2 ("Vienna Reinvented") 15 → 13 stops:
#   drop: Hofpavillon Hietzing · Otto Wagner (#1)
#         Karlskirche becomes the opening stop.
#   drop: Blumengärten Hirschstetten (#13)
class DropThreeMoreViennaStops < ActiveRecord::Migration[8.1]
  HIDDEN_CITY = "The Hidden City"
  VIENNA_REINVENTED = "Vienna Reinvented"

  HIDDEN_CITY_ORDER = [
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
    "Maria am Gestade",
    "Ankeruhr · Hoher Markt",
    "Stock im Eisen",
    "Stephansdom · Türkenkanonenkugel",
    "Wiener Staatsoper",
    "Garten-Palais Liechtenstein",
    "Denkmal der ukrainischen Kosaken · Türkenschanzpark",
    "Jane-Jacobs-Steg · Seestadt Aspern"
  ]

  VIENNA_REINVENTED_ORDER = [
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
    "Copa Beach · Donauinsel",
    "Wiener Riesenrad · Prater"
  ]

  HUNT_1_DROPPED = [
    "Tegetthoff-Denkmal · Praterstern"
  ]

  HUNT_2_DROPPED = [
    "Hofpavillon Hietzing · Otto Wagner",
    "Blumengärten Hirschstetten"
  ]

  def up
    drop_clues_from!(HIDDEN_CITY,       HUNT_1_DROPPED)
    drop_clues_from!(VIENNA_REINVENTED, HUNT_2_DROPPED)
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
