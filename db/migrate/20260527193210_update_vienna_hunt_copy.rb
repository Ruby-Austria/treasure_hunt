class UpdateViennaHuntCopy < ActiveRecord::Migration[8.1]
  HIDDEN_CITY_UPDATES = [
    { seq: 1, title: "The Drawn Curtains",
      riddle: "An emperor drew his curtains. Find what he could not bear to see." },
    { seq: 2, title: "Beneath the Cobbles",
      riddle: "On a Habsburg square, the cobbles open into a glass pit. Two thousand years of soldiers are stacked between you and them." },
    { seq: 3, title: "Noon",
      riddle: "Wait under the bridge between two halves of one building. The hour strikes once a day, in procession." },
    { seq: 4, title: "The Lean",
      riddle: "A church that bends. The river it leans toward is gone." },
    { seq: 5, title: "The Last Stone",
      riddle: "The last stone of the broken wall. A deaf man wrote a symphony on top — and crossed out the name he had dedicated it to." },
    { seq: 6, title: "Bolts in Marble",
      riddle: "A bank that refused to hide its bones. Thousands of aluminum bolts hold up a marble face." },
    { seq: 7, title: "Square and Compass",
      riddle: "Behind an imperial garden gate, a man stands in marble. The flowers at his feet spell music; the carvings on his plinth spell a secret society." },
    { seq: 8, title: "Bloodline",
      riddle: "Behind a Baroque gate, white horses still trace the bloodline of an emperor's stable. Listen for hooves on sand." },
    { seq: 9, title: "The Hero Who Left",
      riddle: "A Greek temple in an imperial garden. Built to hold one statue. The statue moved. The temple stayed." },
    { seq: 10, title: "Iron in Wood",
      riddle: "Where two famous streets meet at the city's busiest corner, a piece of a tree stands behind glass. Five hundred years of strangers each left an iron mark." }
  ]

  VIENNA_REINVENTED_UPDATES = [
    { seq: 1, title: "The Devil's Lines",
      riddle: "A painter believed straight lines were the devil's. He was given a public housing block and proved it." },
    { seq: 2, title: "Round the Corner",
      riddle: "Round the corner from the painter's most famous building, the same fevered hand reshaped an old factory." },
    { seq: 3, title: "Their Age, Their Art",
      riddle: "Above the door: 'To every age its art.' Beneath the dome: two thousand five hundred leaves of gold." },
    { seq: 4, title: "Two Gates",
      riddle: "Two matching gates, green and gold. The railway they served stopped running long ago. They were not built for emperors." },
    { seq: 5, title: "The Compromise",
      riddle: "Two modern boxes inside an emperor's stables. Vienna fought hard enough that the boxes had to sink." },
    { seq: 6, title: "Four Giants",
      riddle: "A kilometer of utopia, painted yellow and red. Four giants stand watch above the central gate: Liberation, Care, Enlightenment, Strength." },
    { seq: 7, title: "The Hollow Drums",
      riddle: "Four brick cylinders that once held the city's gas. They sat empty for fifteen years. Then the basslines came." },
    { seq: 8, title: "The Burning Onion",
      riddle: "A chimney with a golden onion at the top. The painter who hated straight lines designed it. It burns the city's trash." },
    { seq: 9, title: "The Forgotten Painter",
      riddle: "A staircase built for a painter no one remembers. A novelist took its name and made it famous — but not for the painter." },
    { seq: 10, title: "Twenty-Four Carats",
      riddle: "Vienna's most-photographed man stands in a park, playing his violin for nobody. He is cast in twenty-four-carat gold." }
  ]

  def up
    update_clues!("The Hidden City", HIDDEN_CITY_UPDATES)
    update_clues!("Vienna Reinvented", VIENNA_REINVENTED_UPDATES)
    say "Vienna hunt clue copy updated."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def update_clues!(hunt_name, updates)
    hunt = Hunt.find_by(name: hunt_name)
    return say "Skipping #{hunt_name} — hunt not present" unless hunt

    updates.each do |u|
      clue = hunt.clues.find_by(sequence_number: u[:seq])
      next unless clue

      clue.update!(title: u[:title], riddle: u[:riddle])
    end
  end
end
