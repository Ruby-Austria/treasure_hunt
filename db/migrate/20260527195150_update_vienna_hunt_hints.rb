class UpdateViennaHuntHints < ActiveRecord::Migration[8.1]
  HIDDEN_CITY_HINTS = {
    1 => [
      "An emperor closed his curtains so he wouldn't have to see it from the palace.",
      "Its architect wrote the essay 'Ornament and Crime' the same year.",
      "On a small square in the inner city, named for an archangel."
    ],
    2 => [
      "A glass-walled circle set into the pavement of an old square.",
      "Soldiers slept here when Vienna had a Latin name.",
      "Excavated during U-Bahn construction. Look for the cobbles that open downward."
    ],
    3 => [
      "Above an arcade between two halves of one building, a clock counts twelve.",
      "Twelve figures parade across once a day, at noon.",
      "Marcus Aurelius is said to have died on this square."
    ],
    4 => [
      "A Gothic spire on a steep medieval alley near the canal.",
      "Its name means 'on the bank' — but the bank is no longer there.",
      "Napoleon's troops used it as an arsenal."
    ],
    5 => [
      "A scrap of the wall that broke the 1683 siege still stands above the modern street.",
      "Climb the stone staircase next to the University.",
      "Beethoven lived in the house on top while writing the Eroica."
    ],
    6 => [
      "An architect refused to hide the bolts holding his marble façade together.",
      "1906. Heated marble lobby visible through the glass entrance.",
      "On Georg-Coch-Platz, at the eastern edge of the Ring."
    ],
    7 => [
      "A composer in marble, in the Hofburg's private garden.",
      "The flowerbed at his feet is a treble clef.",
      "Square, compass, and sun — the symbols of his most famous opera."
    ],
    8 => [
      "Vienna's oldest equestrian institution, founded in 1572.",
      "White horses, bred in Piber, Styria.",
      "Behind a Baroque gate on Josefsplatz, next to the National Library."
    ],
    9 => [
      "A Greek temple built to hold a single Canova sculpture; the sculpture moved to a museum.",
      "One-fifth scale of the Hephaisteion in Athens.",
      "In the rose garden between the Hofburg and the Burgtheater."
    ],
    10 => [
      "A piece of a tree from 1440, behind glass at a building's corner.",
      "Travelling blacksmith apprentices each drove an iron nail into it for luck.",
      "On the corner where Graben meets Kärntnerstraße — Vienna's busiest crossroads."
    ]
  }

  VIENNA_REINVENTED_HINTS = {
    1 => [
      "An architect renamed himself after rain — 'hundred-water.'",
      "A tree lives on its third storey.",
      "Onion domes on a council block, in Landstraße."
    ],
    2 => [
      "Three blocks from the painter's most famous building, his second one.",
      "A former bentwood-chair factory.",
      "In the 3rd district, between the Hundertwasserhaus and the Donaukanal."
    ],
    3 => [
      "Two thousand five hundred gilded laurel leaves on a windowless white dome.",
      "Built when young artists walked out of the Academy in 1898.",
      "South of the State Opera, at the edge of the Naschmarkt."
    ],
    4 => [
      "Two green-and-gold pavilions facing each other across a great square.",
      "Built for a metropolitan railway that closed in 1925.",
      "South of the State Opera, on either side of a fountain."
    ],
    5 => [
      "Modern cubes inside Fischer von Erlach's old imperial stables.",
      "Vienna fought so hard against the modernism that the cubes had to be sunk into the ground.",
      "Behind the twin Maria-Theresien-Platz museums."
    ],
    6 => [
      "A kilometer of social housing, painted yellow and red.",
      "Four giants over the central gate: Liberation, Care, Enlightenment, Strength.",
      "In Heiligenstadt, the 19th district, on the U4."
    ],
    7 => [
      "Four brick cylinders, built in 1896 to store coal gas for the city's lamps.",
      "Empty for fifteen years; converted to apartments and offices in 2001.",
      "In Simmering, the 11th district, on the U3."
    ],
    8 => [
      "A golden onion crowns a working chimney.",
      "The painter who hated straight lines was asked to redesign it after a fire.",
      "On the Donaukanal, on the U4/U6 line just north of the Ring."
    ],
    9 => [
      "A Jugendstil staircase, built in 1910 for a forgotten Baroque painter.",
      "Heimito von Doderer made it the spine of a 900-page novel in 1951.",
      "In Alsergrund, between Liechtensteinstraße and the street it's named after."
    ],
    10 => [
      "Vienna's most-photographed monument, cast in twenty-four-carat gold.",
      "Edmund Hellmer, 1921. He plays his violin for nobody.",
      "In the Stadtpark, on the eastern Ring."
    ]
  }

  def up
    update_hints!("The Hidden City", HIDDEN_CITY_HINTS)
    update_hints!("Vienna Reinvented", VIENNA_REINVENTED_HINTS)
    say "Vienna hunt hints updated — no place names in the hints; players learn the name on GPS check-in."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def update_hints!(hunt_name, hints_by_sequence)
    hunt = Hunt.find_by(name: hunt_name)
    return say "Skipping #{hunt_name} — hunt not present" unless hunt

    hints_by_sequence.each do |seq, hints|
      clue = hunt.clues.find_by(sequence_number: seq)
      next unless clue

      clue.update!(hints: hints)
    end
  end
end
