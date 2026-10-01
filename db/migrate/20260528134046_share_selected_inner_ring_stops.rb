# Share 5 inner-Ring locations between both hunts so each lands at 20 stops.
#
# Each shared Clue gets its own row (Clue.belongs_to :hunt) but copies
# title / riddle / hints from the existing Clue in the source hunt.
# A player walking both hunts will encounter the same stop twice with
# the same description.
#
# Shared (now in both hunts):
#   - Mozart-Denkmal · Burggarten   (origin: Hunt 2)
#   - Schmetterlinghaus              (origin: Hunt 2)
#   - Schweizertor · Hofburg         (origin: Hunt 2)
#   - Looshaus                       (origin: Hunt 2)
#   - Stephansdom · Türkenkanonenkugel (origin: Hunt 1)
#
# Hunt 1 gains 4 shared stops (slot between Wiener Staatsoper and Stock
# im Eisen — Burggarten + Hofburg cluster).
# Hunt 2 gains 1 shared stop (Stephansdom slots between Looshaus and
# Freyung).
class ShareSelectedInnerRingStops < ActiveRecord::Migration[8.1]
  HIDDEN_CITY = "The Hidden City"
  VIENNA_REINVENTED = "Vienna Reinvented"

  HIDDEN_CITY_ORDER = [
    "Schloss Belvedere",
    "Karlskirche · Karlsplatz",
    "Secession",
    "Wiener Staatsoper",
    "Mozart-Denkmal · Burggarten",                          # SHARED in
    "Schmetterlinghaus",                                    # SHARED in
    "Schweizertor · Hofburg",                               # SHARED in
    "Looshaus",                                             # SHARED in
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
    "Mozart-Denkmal · Burggarten",
    "Schmetterlinghaus",
    "Schweizertor · Hofburg",
    "Vindobona ruins · Michaelerplatz",
    "Looshaus",
    "Stephansdom · Türkenkanonenkugel",                     # SHARED in
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
    reorder_hunt!(HIDDEN_CITY,       HIDDEN_CITY_ORDER)
    reorder_hunt!(VIENNA_REINVENTED, VIENNA_REINVENTED_ORDER)
    say "Hunt 1 → #{HIDDEN_CITY_ORDER.size} stops. Hunt 2 → #{VIENNA_REINVENTED_ORDER.size} stops."
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
          # New shared clue — copy title/riddle/hints from the other hunt's
          # existing clue for this location.
          source_clue = Clue.where(location: location).where.not(hunt_id: hunt.id).first
          unless source_clue
            say "  No source clue found for #{loc_name.inspect} — skipping."
            next
          end

          clue = hunt.clues.build(
            location:   location,
            title:      source_clue.title,
            riddle:     source_clue.riddle,
            hints:      source_clue.hints,
            difficulty: source_clue.difficulty
          )
          say "  Sharing #{loc_name} into #{hunt_name}."
        end

        clue.sequence_number = idx + 1
        clue.save!
      end
    end

    say "Reordered #{hunt_name} (#{ordered_location_names.size} stops)."
  end
end
