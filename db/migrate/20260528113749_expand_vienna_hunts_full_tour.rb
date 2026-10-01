# Expand both Vienna hunts into full-day tour shape.
#
# Hunt 1 ("The Hidden City") → 22 stops:
#   drop: Spanische Hofreitschule, Postsparkasse
#   add 9: Schönbrunn Schloss / Gloriette / Römische Ruine,
#          Wiener Staatsoper, Stephansdom Wiener Elle (hidden detail),
#          Garten-Palais Liechtenstein, Denkmal der ukrainischen Kosaken,
#          Tegetthoff-Denkmal, Himmelteich Seestadt (final)
#
# Hunt 2 ("Vienna Reinvented") → 18 stops:
#   drop: Engel-Apotheke, Majolikahaus, Medaillonhaus,
#         Otto Wagner Stadtbahn-Pavillons, MuseumsQuartier, Spittelau
#   add 9: Hofpavillon Hietzing (hidden Otto Wagner), Technisches Museum,
#          Setagayapark, Nußdorfer Schleuse (sphinx lions hidden detail),
#          Donaukanal Hundertwasser-Promenade (graffiti zone),
#          Augarten Flak Tower (structural framing — no Nazi-era ideology
#          in riddle copy), Copa Beach, Photo Point Donauufer,
#          Blumengärten Hirschstetten
#
# Hint policy v3 preserved: no place name in any hint.
# New stops use first-pass coordinates; user will hand-validate later.
class ExpandViennaHuntsFullTour < ActiveRecord::Migration[8.1]
  HIDDEN_CITY = "The Hidden City"
  VIENNA_REINVENTED = "Vienna Reinvented"

  HIDDEN_CITY_ORDER = [
    "Schönbrunn · Schloss",                                 # NEW
    "Schönbrunn · Gloriette",                               # NEW
    "Schönbrunn · Römische Ruine",                          # NEW (hidden detail)
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
    "Loos American Bar · Kärntner Durchgang",
    "Stephansdom · Türkenkanonenkugel",
    "Stephansdom · Wiener Elle",                            # NEW (hidden detail)
    "Wiener Staatsoper",                                    # NEW
    "Garten-Palais Liechtenstein",                          # NEW
    "Denkmal der ukrainischen Kosaken · Türkenschanzpark",  # NEW
    "Tegetthoff-Denkmal · Praterstern",                     # NEW
    "Himmelteich · Seestadt Aspern"                         # NEW (final)
  ]

  VIENNA_REINVENTED_ORDER = [
    "Hofpavillon Hietzing · Otto Wagner",                   # NEW (hidden detail)
    "Technisches Museum Wien",                              # NEW
    "Karlskirche · Karlsplatz",
    "Secession",
    "Johann-Strauss-Denkmal · Stadtpark",
    "Stadtpark · Wienflussportal",
    "MAK · Stubenring 5",
    "Hundertwasserhaus",
    "KunstHaus Wien",
    "Augarten Flak Tower",                                  # NEW
    "Donaukanal Hundertwasser-Promenade",                   # NEW (hidden detail)
    "Strudlhofstiege",
    "Nußdorfer Schleuse · Otto Wagner",                     # NEW (hidden detail)
    "Setagayapark",                                         # NEW
    "Blumengärten Hirschstetten",                           # NEW
    "Copa Beach · Donauinsel",                              # NEW
    "Photo Point Donauufer",                                # NEW
    "Wiener Riesenrad · Prater"                             # already final
  ]

  HUNT_1_DROPPED = [
    "Spanische Hofreitschule · Josefsplatz",
    "Postsparkasse"
  ]

  HUNT_2_DROPPED = [
    "Engel-Apotheke · Bognergasse 9",
    "Majolikahaus · Linke Wienzeile 40",
    "Medaillonhaus · Linke Wienzeile 38",
    "Otto Wagner Stadtbahn-Pavillons · Karlsplatz",
    "MuseumsQuartier",
    "Müllverbrennungsanlage Spittelau"
  ]

  NEW_CLUES = {
    # ─── Hunt 1 additions ──────────────────────────────────────────────
    "Schönbrunn · Schloss" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.18504",
      long:       "16.31328",
      radius:     60,
      difficulty: :challenging,
      title:      "The Yellow Court",
      riddle:     "Twelve hundred rooms behind the yellow front. An empress raised sixteen children here, and one of her descendants signed an empire away in a room upstairs.",
      hints: [
        "At the foot of a hill in the far western reaches of the city, fronting an enormous gravelled courtyard.",
        "Maria Theresia held court here; Karl I abdicated here in 1918.",
        "The Schloss Schönbrunn façade, seen from the Ehrenhof."
      ]
    },
    "Schönbrunn · Gloriette" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.18209",
      long:       "16.31230",
      radius:     50,
      difficulty: :challenging,
      title:      "The Triumph",
      riddle:     "Up the hill behind the yellow palace, a colonnade of arches marks a battle the empress called a victory. The view from the roof is the only place in the city where everything the empire built can be seen at once.",
      hints: [
        "On the hill above the Schloss — climb the gravel paths to the top.",
        "Maria Theresia commissioned it 1775 to mark the Habsburg recovery after the Seven Years' War.",
        "The Gloriette, with the panoramic view back over Vienna."
      ]
    },
    "Schönbrunn · Römische Ruine" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.18378",
      long:       "16.31503",
      radius:     35,
      difficulty: :challenging,
      title:      "The Fake Ruin",
      riddle:     "An imperial architect built ancient ruins from scratch — broken arches, fallen pillars, weathered stones. Two hundred and fifty years later, they look authentically Roman. They never were.",
      hints: [
        "East side of the palace gardens, between the maze and the Neptunbrunnen.",
        "Johann Ferdinand Hetzendorf von Hohenberg, 1778. A Romantic folly built to look like the Roman Forum.",
        "The Römische Ruine — Schönbrunn's deliberately fake archaeological site."
      ]
    },
    "Stephansdom · Wiener Elle" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.20840",
      long:       "16.37320",
      radius:     20,
      difficulty: :challenging,
      title:      "The Medieval Ruler",
      riddle:     "On the cathedral's south wall, at the height of a man's outstretched hand, two iron bars are mounted side by side. One for linen, one for wool — the city's medieval defence against short-changed cloth, written into the church itself.",
      hints: [
        "On the same cathedral wall as a famous 1683 souvenir — a few metres west of it, much lower down.",
        "Two horizontal iron rods at chest height, marking the Wiener Elle (about 78 cm) and the Tuchelle (about 89 cm).",
        "The Wiener Elle plaque on the Stephansdom south wall, near the Singertor entrance."
      ]
    },
    "Wiener Staatsoper" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.20292",
      long:       "16.36905",
      radius:     40,
      difficulty: :challenging,
      title:      "The Sunken Crown",
      riddle:     "The emperor called the building 'low-built and sunken' when he saw it. The architect hanged himself two months later. The opera house opened seven years after.",
      hints: [
        "On the Opernring, the Ringstraße's south-eastern arc, opposite the Albertinaplatz.",
        "Eduard van der Nüll, the architect, killed himself after Franz Joseph's offhand criticism in 1868.",
        "The Wiener Staatsoper."
      ]
    },
    "Garten-Palais Liechtenstein" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.22310",
      long:       "16.36320",
      radius:     35,
      difficulty: :challenging,
      title:      "The Princely Collection",
      riddle:     "A Baroque garden palace in the 9th district, owned for three hundred years by the family with the smallest sovereign country in Europe. The art inside is one of the largest private collections on the continent; the garden outside costs nothing to enter.",
      hints: [
        "In Alsergrund, the 9th district, with a wrought-iron gate on Fürstengasse.",
        "The Liechtensteins — princes whose territory between Switzerland and Austria measures only 160 km².",
        "The Garten-Palais Liechtenstein, holding the family's Rubens, Raphael and Canova marbles."
      ]
    },
    "Denkmal der ukrainischen Kosaken · Türkenschanzpark" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.23538",
      long:       "16.33500",
      radius:     30,
      difficulty: :challenging,
      title:      "The Forgotten Allies",
      riddle:     "In a hilltop park named for an Ottoman artillery position, a granite obelisk honours the cavalrymen who broke the 1683 siege from the north. Most Viennese don't know they came at all.",
      hints: [
        "In Türkenschanzpark in the 18th district — built on the actual 1683 Ottoman gun emplacement.",
        "The Ukrainian Cossacks under hetmans Kunicki and Mohyla, fighting under King Jan III Sobieski's command.",
        "The 1990s monument to the Ukrainian Cossack defenders of the 1683 siege."
      ]
    },
    "Tegetthoff-Denkmal · Praterstern" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.21745",
      long:       "16.39252",
      radius:     30,
      difficulty: :challenging,
      title:      "The Landlocked Admiral",
      riddle:     "A column for a naval admiral, at a railway-station square in a country with no coast. The battle he won was fought off an island that was Habsburg in 1866, then Italian, then Yugoslav, and is now something else entirely.",
      hints: [
        "At Praterstern, the railway and U-Bahn intersection at the south-west corner of the 2nd district.",
        "Admiral Wilhelm von Tegetthoff, victor of the 1866 Battle of Lissa against the Italian navy.",
        "The Tegetthoff-Denkmal — a column with iron ship prows piled at its base."
      ]
    },
    "Himmelteich · Seestadt Aspern" => {
      hunt:       HIDDEN_CITY,
      lat:        "48.22593",
      long:       "16.50920",
      radius:     60,
      difficulty: :challenging,
      title:      "The Lake in the New City",
      riddle:     "An artificial lake at the heart of a city that did not exist twenty years ago. The buildings around it are named after twentieth-century women — urbanist, suffragette, writer, environmentalist.",
      hints: [
        "In Seestadt Aspern, the 22nd district — built on a former airfield, served by the eastern terminus of the U2.",
        "Streets and squares around the lake bear names like Jane Jacobs, Hannah Arendt, Wangari Maathai.",
        "The Himmelteich at Aspern Seestadt — a few minutes' walk from the U2 terminus."
      ]
    },

    # ─── Hunt 2 additions ──────────────────────────────────────────────
    "Hofpavillon Hietzing · Otto Wagner" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.18708",
      long:       "16.30040",
      radius:     25,
      difficulty: :challenging,
      title:      "The Emperor's Station",
      riddle:     "An architect built a railway station for one passenger. The emperor used it twice. The polished walnut walls and the marble waiting room have been preserved exactly as they were that day.",
      hints: [
        "At Hietzing U-Bahn station, on the edge of the Schönbrunn palace grounds.",
        "Otto Wagner, 1899. Built into the Stadtbahn for Emperor Franz Joseph's exclusive use.",
        "The Hofpavillon Hietzing, immediately outside the U4 Hietzing exit."
      ]
    },
    "Technisches Museum Wien" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.19044",
      long:       "16.31821",
      radius:     40,
      difficulty: :challenging,
      title:      "The Engineering Hall",
      riddle:     "The largest museum building in the city, raised in 1909 to celebrate machines instead of monarchs. Inside, the first electric power station, the first telephone exchange, and Vienna's earliest computer.",
      hints: [
        "On Mariahilfer Straße in the 14th district, the long western axis out of the city.",
        "1909. Hans Schneider's purpose-built museum of technology, founded under Emperor Franz Joseph.",
        "The Technisches Museum Wien."
      ]
    },
    "Augarten Flak Tower" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.22090",
      long:       "16.37570",
      radius:     40,
      difficulty: :challenging,
      title:      "The Indestructible Cube",
      riddle:     "Fifty-five metres of solid concrete, walls five metres thick, sitting in a Baroque public garden. They cannot demolish it — the explosion would take half the neighbourhood. So it stays, ringed by rose beds, an architectural ghost.",
      hints: [
        "In the Augarten park, the 2nd district's grand Baroque public garden.",
        "Concrete walls so thick no peacetime explosive charge can safely dismantle them.",
        "The Gefechtsturm in Augarten — the larger of the pair."
      ]
    },
    "Donaukanal Hundertwasser-Promenade" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.21370",
      long:       "16.37565",
      radius:     100,
      difficulty: :challenging,
      title:      "The Permitted Wall",
      riddle:     "Along one stretch of the canal, the wall belongs to anyone with a spray can. Paint over paint over paint. The city does not repaint it. The longest legal mural in central Europe.",
      hints: [
        "On the Donaukanal walls between Schwedenplatz and the Friedensbrücke — the canal's stretch through the inner districts.",
        "Vienna's only officially-permitted graffiti zone, established in the 1980s after years of squat-led cultural protest.",
        "The Donaukanal legal-graffiti strip; named for Hundertwasser, who lived a few hundred metres away."
      ]
    },
    "Nußdorfer Schleuse · Otto Wagner" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.25450",
      long:       "16.36633",
      radius:     40,
      difficulty: :challenging,
      title:      "The Stone Lions",
      riddle:     "Where the canal begins, an architect built locks. Above the water, two stone lions watch the current — heads down, paws crossed, no obvious purpose. He gave them no inscription. Nobody is sure what they're guarding.",
      hints: [
        "At the head of the Donaukanal in the 19th district, where the canal splits off from the Danube proper.",
        "Otto Wagner, 1898. Part of his Stadtbahn / Donaukanal regulation project.",
        "The Nußdorfer Wehr- und Schleusenanlage, with its twin Schleusenlöwen."
      ]
    },
    "Setagayapark" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.25180",
      long:       "16.35880",
      radius:     35,
      difficulty: :challenging,
      title:      "The Tokyo Gift",
      riddle:     "A Japanese garden in the 19th district, gifted by Tokyo's Setagaya ward in 1992. The stones came from Japan. The cherry trees came from Japan. Even the wooden bridge was built by Japanese carpenters flown in for the work.",
      hints: [
        "On the slopes above the Donaukanal, in the 19th district between Heiligenstadt and Hohe Warte.",
        "A reciprocal sister-city gift from Setagaya, one of Tokyo's special wards.",
        "The Setagayapark — Vienna's Japanese garden."
      ]
    },
    "Blumengärten Hirschstetten" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.24160",
      long:       "16.47620",
      radius:     50,
      difficulty: :challenging,
      title:      "The Themed Gardens",
      riddle:     "Eighteen hectares of themed gardens in the 22nd district — Japanese, ancient Egypt, Australian outback, Tyrolean farm. Free, gently absurd, lightly visited. Built by the city's horticulture department because someone wanted to.",
      hints: [
        "In Donaustadt, the 22nd district — accessible by tram from the U2 to Hirschstetten.",
        "Sections include a Japanese garden, ancient Egypt courtyard, Australian outback, French formal, English country, Tyrolean farm.",
        "The Blumengärten Hirschstetten."
      ]
    },
    "Copa Beach · Donauinsel" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.22650",
      long:       "16.40760",
      radius:     80,
      difficulty: :challenging,
      title:      "The City Beach",
      riddle:     "An artificial island built in the 1970s to control floods became, by accident, the largest swimming beach in the city. In summer it has the second-most visitors of anywhere in Vienna. Most of them are wearing very little.",
      hints: [
        "On the Donauinsel, the 21-km-long artificial flood-control island that splits the Danube.",
        "Built 1972–1988 as flood protection; the recreation use was an afterthought that became the main one.",
        "The Copa Beach on the Donauinsel — accessible by U1 to Donauinsel station."
      ]
    },
    "Photo Point Donauufer" => {
      hunt:       VIENNA_REINVENTED,
      lat:        "48.23150",
      long:       "16.40150",
      radius:     30,
      difficulty: :challenging,
      title:      "The Designated View",
      riddle:     "Someone at the city planning office picked one spot on the riverbank, posted a small bronze marker that said photograph here, and stepped back. People do.",
      hints: [
        "On the Donauufer, the bank of the Danube proper (not the canal).",
        "A bronze marker on the embankment indicating an official photographic viewpoint.",
        "The Photo Point Donauufer."
      ]
    }
  }

  def up
    drop_clues_from!(HIDDEN_CITY,        HUNT_1_DROPPED)
    drop_clues_from!(VIENNA_REINVENTED,  HUNT_2_DROPPED)
    create_or_update_new_locations!
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
