# Hint policy v3 audit & fix:
#
#   Rule: NO place name (of THIS clue's destination) appears in any hint.
#         Player learns the place name only via GPS check-in.
#
# Older clues rewritten under v3 (Karlskirche, Looshaus, Stock im Eisen,
# Mozart-Denkmal, Schweizertor, etc.) all comply. The newer additions
# from expansion migrations violated by spelling the destination out
# in hint 3.
#
# This migration rewrites hint 3 for the 13 violating clues. For shared
# locations (Mozart, Schmetterlinghaus, Schweizertor, Looshaus,
# Stephansdom) we touch the Clue rows in BOTH hunts so the copy stays
# consistent.
class FixHintV3ViolationsAcrossHunts < ActiveRecord::Migration[8.1]
  # New hint 3 keyed by Location name. Affects every Clue row pointing
  # at that Location, regardless of which hunt it lives in.
  HINT_3_FIXES = {
    "Wiener Staatsoper" =>
      "Built 1861–1869; Mahler conducted his decade of controversial premieres here.",

    "Schloss Belvedere" =>
      "Klimt's The Kiss lives in the upper palace. Gardens free; palace ticketed.",

    "Schönbrunn · Schloss" =>
      "The yellow palace front, seen from the great gravelled forecourt called the Ehrenhof.",

    "Schönbrunn · Römische Ruine" =>
      "An eighteenth-century Romantic folly built to look like ancient ruins — in the eastern half of the palace gardens.",

    "Schönbrunn · Gloriette" =>
      "The hilltop colonnade with the panoramic view back over the city.",

    "Technisches Museum Wien" =>
      "Founded under Emperor Franz Joseph; inside, the first electric power station, the first telephone exchange, and the country's earliest computer.",

    "Haus des Meeres" =>
      "Exterior climbing wall up one side; panoramic café on the roof. Visible from any high point in the 6th district.",

    "Schmetterlinghaus" =>
      "An iron-and-glass pavilion at the south end of the imperial back garden — exterior view free, butterflies ticketed.",

    "Donaukanal Hundertwasser-Promenade" =>
      "Hundertwasser lived a few hundred metres away. The city quietly stopped enforcing graffiti laws on this stretch in the 1980s.",

    "Copa Beach · Donauinsel" =>
      "Accessible by U1 to the island station; busy on summer weekends, all but empty in winter.",

    "Jane-Jacobs-Steg · Seestadt Aspern" =>
      "Cross the bridge to reach the lake at the heart of the city's newest district — a few minutes' walk from the U2 terminus.",

    "Garten-Palais Liechtenstein" =>
      "A princely garden palace in Alsergrund, holding the family's Rubens, Raphael, and Canova marbles.",

    "Setagayapark" =>
      "The only Japanese garden in the city, free to enter from dawn to dusk.",

    "Augarten Flak Tower" =>
      "The larger of the pair, deeper inside the Baroque park than the other."
  }

  def up
    HINT_3_FIXES.each do |loc_name, new_hint_3|
      location = Location.find_by(name: loc_name, city: "Vienna")
      next unless location

      clues = Clue.where(location: location).to_a
      clues.each do |clue|
        hints = clue.hints.dup
        next unless hints.is_a?(Array) && hints.size >= 3
        hints[2] = new_hint_3
        clue.update!(hints: hints)
      end
      say "Fixed hint 3 on #{clues.size} clue(s) for #{loc_name}."
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
