class ImportViennaHunts < ActiveRecord::Migration[8.1]
  HUNTS = [
    {
      name: "The Hidden City",
      description: "Vienna keeps its secrets in plain sight. Ten stops trace the codes carved into the inner city — where Romans, Habsburgs, modernists and stonemasons hid their meaning in the buildings most people walk past.",
      difficulty: :challenging,
      hunt_type: :reward,
      completion_message: "You read what most visitors miss. Now claim the chest.",
      clues: [
        {
          title: "The Face Without Eyebrows",
          riddle: "An emperor closed his curtains rather than look at it. Find the building that gave Vienna a face by refusing to wear one.",
          hints: [
            "On the square named for an archangel, opposite the great green dome of the imperial palace.",
            "Its architect called ornament a crime; Franz Joseph agreed and shuttered the Hofburg windows facing it.",
            "The Looshaus on Michaelerplatz."
          ],
          location: { name: "Looshaus", lat: 48.2076, long: 16.3661, unlock_radius: 25 }
        },
        {
          title: "The Underfoot Camp",
          riddle: "On the same square as the face that needs no ornament, the cobbles open into a glass-walled pit. Stand at its edge and you are above the bones of a Roman fort that gave Vienna its first name.",
          hints: [
            "The square in front of the Hofburg, where horses still pass under the dome.",
            "A circular sunken excavation in the middle of the pedestrian zone — officers' quarters of a legionary camp.",
            "Vindobona ruins on Michaelerplatz."
          ],
          location: { name: "Vindobona ruins · Michaelerplatz", lat: 48.2076, long: 16.3664, unlock_radius: 25 }
        },
        {
          title: "The Twelve Witnesses",
          riddle: "At noon, twelve figures cross a gilded bridge above an old market square — emperor, poet, composer, prince. Each carries a year. Watch them and a thousand years of Vienna pass overhead.",
          hints: [
            "The city's oldest square, where Marcus Aurelius is said to have died.",
            "The clock spans an arcade between two parts of the Anker insurance company building.",
            "The Ankeruhr on Hoher Markt."
          ],
          location: { name: "Ankeruhr · Hoher Markt", lat: 48.2117, long: 16.3744, unlock_radius: 25 }
        },
        {
          title: "The Bent Nave",
          riddle: "A Gothic church whose stones remember a river that no longer exists. The nave bends because the architect followed a shoreline that has since been buried under streets.",
          hints: [
            "A steep medieval alley in the 1st district, close to the Donaukanal.",
            "Under Napoleon it was an arsenal; under Joseph II, a horse stable.",
            "Maria am Gestade — \"Mary on the Bank.\""
          ],
          location: { name: "Maria am Gestade", lat: 48.2128, long: 16.3704, unlock_radius: 30 }
        },
        {
          title: "The Last Wall",
          riddle: "A scrap of medieval rampart still standing in the middle of the modern city — the last surviving piece of the wall that broke an Ottoman siege. A deaf man composed an emperor's symphony at its top, then scratched out the emperor's name when he became one.",
          hints: [
            "An elevated stone terrace near the University, accessible by a public staircase.",
            "Beethoven lived in the house on top while writing the Eroica.",
            "Mölker Bastei and the Pasqualatihaus."
          ],
          location: { name: "Mölker Bastei · Pasqualatihaus", lat: 48.2138, long: 16.3640, unlock_radius: 35 }
        },
        {
          title: "Manifesto in Aluminum",
          riddle: "A bank that refused to hide its rivets. Thousands of aluminum bolts pin a marble façade — modernism's first manifesto, written in screws, three years before the building without eyebrows.",
          hints: [
            "On Georg-Coch-Platz, at the eastern edge of the Ring.",
            "Otto Wagner, 1906; the heated marble counter hall is visible through the glass entrance.",
            "The Postsparkasse — Austrian Postal Savings Bank."
          ],
          location: { name: "Postsparkasse", lat: 48.2102, long: 16.3795, unlock_radius: 40 }
        },
        {
          title: "The Composer's Garden",
          riddle: "A composer carved in marble stands in an imperial garden. The flowerbed at his feet is shaped like a treble clef, and the symbols on his plinth confess what his most famous opera only whispered.",
          hints: [
            "The Habsburg garden between the Hofburg and the Ring.",
            "The plinth bears Freemason imagery — square, compass, sun — keys to The Magic Flute.",
            "The Mozart-Denkmal in the Burggarten."
          ],
          location: { name: "Mozart-Denkmal · Burggarten", lat: 48.2057, long: 16.3651, unlock_radius: 30 }
        },
        {
          title: "The Imperial Bloodline",
          riddle: "The oldest classical riding school in the world stands behind a Baroque gate. Every horse on its sand is a great-great-great-grandchild of a Habsburg mount — a four-hundred-fifty-year genealogy still measured in hoofbeats.",
          hints: [
            "Josefsplatz, beside the National Library and across from the Albertina.",
            "The Lipizzaner horses are bred in Piber, Styria; you can hear them through the Stallburg's gates.",
            "The Spanish Riding School (Spanische Hofreitschule)."
          ],
          location: { name: "Spanische Hofreitschule · Josefsplatz", lat: 48.2074, long: 16.3666, unlock_radius: 35 }
        },
        {
          title: "The Empty Greek Temple",
          riddle: "An Athenian temple, one-fifth scale, built in a Habsburg park to house a single statue. The marble hero — Theseus killing the centaur — has since moved into a museum. The shrine remains empty.",
          hints: [
            "In the Volksgarten, just inside the Ring opposite the Hofburg.",
            "The Canova sculpture it was built for is now in the Kunsthistorisches Museum's grand staircase.",
            "The Theseustempel."
          ],
          location: { name: "Theseustempel · Volksgarten", lat: 48.2072, long: 16.3608, unlock_radius: 30 }
        },
        {
          title: "The Petrified Witness",
          riddle: "At Vienna's busiest pedestrian corner, a glass case holds a piece of a tree from 1440. Travelling blacksmith apprentices hammered an iron nail into it for luck before leaving the city. Over five centuries, the bark vanished under the nails. Most people walk past without seeing it.",
          hints: [
            "At the southern end of the Graben, where it meets Kärntnerstraße.",
            "Embedded in the corner of a building, behind glass at eye level.",
            "The Stock im Eisen — \"staff in iron.\""
          ],
          location: { name: "Stock im Eisen", lat: 48.2079, long: 16.3714, unlock_radius: 20 }
        }
      ]
    },
    {
      name: "Vienna Reinvented",
      description: "Vienna is not all empire and waltz. Ten stops trace the buildings, blocks and monuments that refused the imperial line — the painters, planners and architects who reshaped the city out of spite, optimism, or pure aesthetic war.",
      difficulty: :challenging,
      hunt_type: :reward,
      completion_message: "You followed the city's quieter rebellion. Claim your reward.",
      clues: [
        {
          title: "No Straight Lines",
          riddle: "A painter called straight lines \"the work of the devil\" and built a public housing block as proof. No two windows match, the floors refuse to lie flat, and a tree grows from a third-storey window.",
          hints: [
            "Landstraße, the 3rd district, east of the Ring.",
            "Friedensreich Hundertwasser, 1985. The painter's house — not the museum.",
            "The Hundertwasserhaus on Kegelgasse."
          ],
          location: { name: "Hundertwasserhaus", lat: 48.2076, long: 16.3938, unlock_radius: 35 }
        },
        {
          title: "The Painter's Other House",
          riddle: "Around the corner from the painter's most famous building stands his second one. A former bentwood-chair factory turned upside-down by the same restless hand. The same drunken floors, the same fevered tiles, but this one is open to the public.",
          hints: [
            "Three blocks north of the Hundertwasserhaus, also in the 3rd district.",
            "Originally a furniture factory; now houses Hundertwasser's archive.",
            "The KunstHaus Wien."
          ],
          location: { name: "KunstHaus Wien", lat: 48.2110, long: 16.3920, unlock_radius: 30 }
        },
        {
          title: "The Golden Cabbage",
          riddle: "When a group of young artists seceded from the academy in 1898, they crowned their new building with two-thousand-five-hundred gilded laurel leaves. Locals called it the cabbage. Carved above the door: To every age its art. To art its freedom.",
          hints: [
            "South of the State Opera, at the western edge of the Naschmarkt.",
            "Architect Joseph Maria Olbrich, 1898. Klimt's Beethoven Frieze hangs inside (but stay outside for this).",
            "The Secession building."
          ],
          location: { name: "Secession", lat: 48.2007, long: 16.3656, unlock_radius: 30 }
        },
        {
          title: "The Bankrupt Railway",
          riddle: "Two green-and-gold gates to a metropolitan railway that bankrupted everyone who built it. The trains stopped running a century ago. The pavilions stayed — Vienna's first Jugendstil monument, built for commuters instead of emperors.",
          hints: [
            "On either side of Karlsplatz, the great square south of the Opera.",
            "Otto Wagner, 1899. Built for the old Wiener Stadtbahn metropolitan line.",
            "The Karlsplatz Stadtbahn-Pavillons."
          ],
          location: { name: "Otto Wagner Stadtbahn-Pavillons · Karlsplatz", lat: 48.2002, long: 16.3699, unlock_radius: 30 }
        },
        {
          title: "The Cubes That Had to Bow",
          riddle: "Two modernist cubes were built inside the emperor's old horse stables. The planners fought so hard against the modernism that the cubes had to be sunk into the ground — anything taller would have spoiled the imperial roofline. The compromise is the architecture.",
          hints: [
            "Behind the twin Maria-Theresien-Platz museums, between the 7th and 1st districts.",
            "The Leopold Museum + MUMOK. Sit on the colored Enzi benches in the courtyard.",
            "The MuseumsQuartier (MQ)."
          ],
          location: { name: "MuseumsQuartier", lat: 48.2030, long: 16.3589, unlock_radius: 50 }
        },
        {
          title: "The Workers' Palace",
          riddle: "One-and-a-tenth kilometers of social-housing utopia. Above the central tower stand four giant statues: Liberation, Care, Enlightenment, Physical Strength — the workers' answer to imperial allegory, cast in stone five times life-size.",
          hints: [
            "North of the city in Döbling, beside the Heiligenstadt U-Bahn (U4).",
            "Built 1927–1930 as the manifesto of \"Red Vienna\" under mayor Karl Seitz.",
            "The Karl-Marx-Hof."
          ],
          location: { name: "Karl-Marx-Hof", lat: 48.2519, long: 16.3585, unlock_radius: 60 }
        },
        {
          title: "Brick Cathedrals to Gas",
          riddle: "Four enormous brick cylinders built in 1896 to hold coal gas for the city's lamps. When gas was abandoned, they sat empty for fifteen years; techno collectives turned them into illegal raves. Now they hold apartments, but the brick exteriors are untouched.",
          hints: [
            "In Simmering, the 11th district, on the U3 line.",
            "Built 1896–1899; converted to housing 2001.",
            "The Gasometer."
          ],
          location: { name: "Gasometer", lat: 48.1858, long: 16.4205, unlock_radius: 50 }
        },
        {
          title: "The Golden Onion Over Trash",
          riddle: "A golden onion crowns a chimney over a furnace that burns the city's garbage. After the original plant caught fire in 1987, the painter who hated straight lines was asked to redesign it. He insisted it had to be art that also runs the waste cycle.",
          hints: [
            "On the Donaukanal, on the U4 / U6 line just north of the Ring.",
            "Hundertwasser, 1992. Visible from the U-Bahn and from across the canal.",
            "The Spittelau incinerator."
          ],
          location: { name: "Müllverbrennungsanlage Spittelau", lat: 48.2363, long: 16.3573, unlock_radius: 40 }
        },
        {
          title: "The Literary Staircase",
          riddle: "A Jugendstil staircase built in 1910 in honor of a forgotten Baroque painter. Forty years later, a novelist made it the spine of a 900-page novel. Today everyone who climbs it remembers him; almost no one remembers the painter.",
          hints: [
            "In Alsergrund, the 9th district, between Liechtensteinstraße and Strudlhofgasse.",
            "The novel is Heimito von Doderer's Die Strudlhofstiege (1951); the painter is Peter Strudel.",
            "The Strudlhofstiege."
          ],
          location: { name: "Strudlhofstiege", lat: 48.2229, long: 16.3596, unlock_radius: 30 }
        },
        {
          title: "The Gilded Waltz King",
          riddle: "Vienna's most-photographed monument: a man playing his violin for nobody, cast in twenty-four-carat gold under a marble arch. The most absurd and the most famous at once — a city's tribute to the music that made it dance.",
          hints: [
            "In the Stadtpark, on the eastern Ring.",
            "Edmund Hellmer, 1921. Johann Strauss II — the waltz king.",
            "The gilded Strauss-Denkmal in the Stadtpark."
          ],
          location: { name: "Johann-Strauss-Denkmal · Stadtpark", lat: 48.2052, long: 16.3793, unlock_radius: 30 }
        }
      ]
    }
  ]

  def up
    HUNTS.each do |hunt_spec|
      hunt = Hunt.find_or_initialize_by(name: hunt_spec[:name])
      hunt.assign_attributes(
        description: hunt_spec[:description],
        status: :approved,
        difficulty: hunt_spec[:difficulty],
        hunt_type: hunt_spec[:hunt_type],
        language: "en",
        completion_message: hunt_spec[:completion_message]
      )
      hunt.save!

      hunt_spec[:clues].each_with_index do |clue_spec, index|
        loc_spec = clue_spec[:location]
        location = Location.find_or_initialize_by(name: loc_spec[:name], city: "Vienna")
        location.assign_attributes(
          country: "Austria",
          lat: loc_spec[:lat],
          long: loc_spec[:long],
          unlock_radius: loc_spec[:unlock_radius],
          difficulty: hunt_spec[:difficulty]
        )
        location.save!

        clue = Clue.find_or_initialize_by(hunt: hunt, location: location)
        clue.assign_attributes(
          sequence_number: index + 1,
          title: clue_spec[:title],
          riddle: clue_spec[:riddle],
          hints: clue_spec[:hints],
          difficulty: hunt_spec[:difficulty]
        )
        clue.save!
      end
    end

    say "Hunts imported: #{Hunt.count} hunts, #{Clue.count} clues, #{Location.count} locations"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
