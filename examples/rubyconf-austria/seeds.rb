# RubyConf Austria 2026 — the two hunts that ran in Vienna, May 29–31 2026.
# Load with:  bin/rails runner examples/rubyconf-austria/seeds.rb
# Locations are shared across hunts and deduplicated by name + city.

hunt1 = Hunt.find_or_create_by!(name: "The Hidden City") do |hunt|
  description: "Vienna keeps its secrets in plain sight. Ten stops trace the codes carved into the inner city — where Romans, Habsburgs, modernists and stonemasons hid their meaning in the buildings most people walk past.",
  status: "approved",
  difficulty: "challenging",
  hunt_type: "reward",
  price: "0.0",
  language: "en",
  completion_message: "You read what most visitors miss. Now claim the chest — reach out to Muhamed with the phrase \"I need the secret key\" and he'll provide one.",
  theme: nil,
  persona: nil,
  center_lat: nil,
  center_lng: nil,
  total_distance_meters: nil,
  estimated_duration_min: nil,
  treasure_location: "Wangari-Maathai-Platz 3, 1220 Wien, Austria",
  treasure_access_code: "28736855",
  treasure_hint: "At the address, look for a MyFlexBox parcel locker. Enter the code 28736855 to open it. If it doesn't work, reach out to Muhamed with the phrase \"I need the secret key\"."
end

hunt2 = Hunt.find_or_create_by!(name: "Vienna Reinvented") do |hunt|
  description: "Vienna is not all empire and waltz. Ten stops trace the buildings, blocks and monuments that refused the imperial line — the painters, planners and architects who reshaped the city out of spite, optimism, or pure aesthetic war.",
  status: "approved",
  difficulty: "challenging",
  hunt_type: "reward",
  price: "0.0",
  language: "en",
  completion_message: "You followed the city's quieter rebellion. Claim your reward — reach out to Muhamed with the phrase \"I need the secret key\" and he'll provide one.",
  theme: nil,
  persona: nil,
  center_lat: nil,
  center_lng: nil,
  total_distance_meters: nil,
  estimated_duration_min: nil,
  treasure_location: "Nordbahnstraße 51, 1020 Wien, Austria",
  treasure_access_code: "87205150",
  treasure_hint: "At the address, look for a MyFlexBox parcel locker. Enter the code 87205150 to open it. If it doesn't work, reach out to Muhamed with the phrase \"I need the secret key\"."
end

# --- The Hidden City (19 stops) ---
loc = Location.find_or_create_by!(name: "Schloss Belvedere", city: "Vienna") do |location|
  lat: "48.1916388",
  long: "16.3808849",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "South of Schwarzenbergplatz, on the road named after the prince who built it.",
    "Prince Eugen of Savoy, 1717–1723. Architect Johann Lukas von Hildebrandt.",
    "Klimt's The Kiss lives in the upper palace. Gardens free; palace ticketed.",
  ],
  fun_fact: nil,
  sequence_number: 1,
  riddle: "A soldier-prince built two Baroque palaces and formal gardens to outshine the emperor. The most-reproduced painting in the city hangs in the upper one — but he died two hundred years before it was painted.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Soldier's Palace"
end

loc = Location.find_or_create_by!(name: "Karlskirche · Karlsplatz", city: "Vienna") do |location|
  lat: "48.1985167",
  long: "16.3719305",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "On a wide square south of the State Opera, between two of the inner Ring's largest fountains.",
    "Johann Bernhard Fischer von Erlach, 1716–1737. Charles VI's vow against the 1713 plague.",
    "A Baroque dome flanked by two spiralling Trajan-style columns covered in reliefs.",
  ],
  fun_fact: nil,
  sequence_number: 2,
  riddle: "Two stone columns rise like wound trumpets beside a green-copper dome. An emperor built this when his city stopped dying of plague — and copied the columns straight from Trajan's victory pillar in Rome.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Wound Trumpets"
end

loc = Location.find_or_create_by!(name: "Secession", city: "Vienna") do |location|
  lat: "48.2005257",
  long: "16.3657705",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "Two thousand five hundred gilded laurel leaves on a windowless white dome.",
    "Built when young artists walked out of the Academy in 1898.",
    "South of the State Opera, at the edge of the Naschmarkt.",
  ],
  fun_fact: nil,
  sequence_number: 3,
  riddle: "Above the door: 'To every age its art.' Beneath the dome: two thousand five hundred leaves of gold.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "Their Age, Their Art"
end

loc = Location.find_or_create_by!(name: "Wiener Staatsoper", city: "Vienna") do |location|
  lat: "48.2035735",
  long: "16.3691497",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "On the Opernring, the Ringstraße's south-eastern arc, opposite the Albertinaplatz.",
    "Eduard van der Nüll, the architect, killed himself after Franz Joseph's offhand criticism in 1868.",
    "Built 1861–1869; Mahler conducted his decade of controversial premieres here.",
  ],
  fun_fact: nil,
  sequence_number: 4,
  riddle: "The emperor called the building 'low-built and sunken' when he saw it. The architect hanged himself two months later. The opera house opened seven years after.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Sunken Crown"
end

loc = Location.find_or_create_by!(name: "Mozart-Denkmal · Burggarten", city: "Vienna") do |location|
  lat: "48.2044883",
  long: "16.3659087",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 150,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "A composer in marble, in the Hofburg's private garden.",
    "The flowerbed at his feet is a treble clef.",
    "Square, compass, and sun — the symbols of his most famous opera.",
  ],
  fun_fact: nil,
  sequence_number: 5,
  riddle: "Behind an imperial garden gate, a man stands in marble. The flowers at his feet spell music; the carvings on his plinth spell a secret society.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "Square and Compass"
end

loc = Location.find_or_create_by!(name: "Schmetterlinghaus", city: "Vienna") do |location|
  lat: "48.205669",
  long: "16.3662895",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "In the small palace garden between the imperial residence and the Ringstraße — a tall glass house at the south end.",
    "Friedrich Ohmann + Ludwig Beermann, 1901. Originally a Palmenhaus; the butterfly conservatory was added in 1998.",
    "An iron-and-glass pavilion at the south end of the imperial back garden — exterior view free, butterflies ticketed.",
  ],
  fun_fact: nil,
  sequence_number: 6,
  riddle: "An Art Nouveau pavilion of iron and glass, set in the imperial back garden. Inside, hundreds of tropical butterflies fly free. The architect built it for palms; the butterflies came almost a hundred years later.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "Wings Behind Glass"
end

loc = Location.find_or_create_by!(name: "Schweizertor · Hofburg", city: "Vienna") do |location|
  lat: "48.2066",
  long: "16.36546",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "A Renaissance gate, painted in Habsburg red and white, deep inside the imperial palace's inner courtyard.",
    "Five vowels in sequence — the personal motto of Frederick III, decoded a dozen ways and never settled.",
    "Pass through the Michaelertrakt; the gate is on the western wall of the Innerer Burghof, just before the Schatzkammer entrance.",
  ],
  fun_fact: nil,
  sequence_number: 7,
  riddle: "An emperor signed everything with five letters: A · E · I · O · U. Six centuries later, nobody agrees what they meant. The painted gate at the heart of the imperial palace bears them above its arch.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Five Letters"
end

loc = Location.find_or_create_by!(name: "Looshaus", city: "Vienna") do |location|
  lat: "48.2084285",
  long: "16.3667315",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 80,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "An emperor closed his curtains so he wouldn't have to see it from the palace.",
    "Its architect wrote the essay 'Ornament and Crime' the same year.",
    "On a small square in the inner city, named for an archangel.",
  ],
  fun_fact: nil,
  sequence_number: 8,
  riddle: "An emperor drew his curtains. Find what he could not bear to see.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Drawn Curtains"
end

loc = Location.find_or_create_by!(name: "Stock im Eisen", city: "Vienna") do |location|
  lat: "48.2084401",
  long: "16.3719073",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "A piece of a tree from 1440, behind glass at a building's corner.",
    "Travelling blacksmith apprentices each drove an iron nail into it for luck.",
    "On the corner where Graben meets Kärntnerstraße — Vienna's busiest crossroads.",
  ],
  fun_fact: nil,
  sequence_number: 9,
  riddle: "Where two famous streets meet at the city's busiest corner, a piece of a tree stands behind glass. Five hundred years of strangers each left an iron mark.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "Iron in Wood"
end

loc = Location.find_or_create_by!(name: "Stephansdom · Türkenkanonenkugel", city: "Vienna") do |location|
  lat: "48.2084538",
  long: "16.3734842",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 80,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "Look up — the south buttress of the city's tallest church, just below the eaves.",
    "Iron, smooth, the size of a melon. A small plaque dates it to the year of the second siege.",
    "On the south face of the cathedral whose spire dominates the inner-city skyline.",
  ],
  fun_fact: nil,
  sequence_number: 10,
  riddle: "A dark sphere is buried high in the cathedral's south wall. It was fired in 1683. Nobody removed it.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Souvenir"
end

loc = Location.find_or_create_by!(name: "Ankeruhr · Hoher Markt", city: "Vienna") do |location|
  lat: "48.2110861",
  long: "16.3734099",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "Above an arcade between two halves of one building, a clock counts twelve.",
    "Twelve figures parade across once a day, at noon.",
    "Marcus Aurelius is said to have died on this square.",
  ],
  fun_fact: nil,
  sequence_number: 11,
  riddle: "Wait under the bridge between two halves of one building. The hour strikes once a day, in procession.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "Noon"
end

loc = Location.find_or_create_by!(name: "Maria am Gestade", city: "Vienna") do |location|
  lat: "48.2130262",
  long: "16.370005",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "A Gothic spire on a steep medieval alley near the canal.",
    "Its name means 'on the bank' — but the bank is no longer there.",
    "Napoleon's troops used it as an arsenal.",
  ],
  fun_fact: nil,
  sequence_number: 12,
  riddle: "A church that bends. The river it leans toward is gone.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Lean"
end

loc = Location.find_or_create_by!(name: "MAK · Stubenring 5", city: "Vienna") do |location|
  lat: "48.20881",
  long: "16.37956",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 200,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "On the Ringstrasse where it meets the Stadtpark, at the corner of Stubenring and Weiskirchnerstraße.",
    "Heinrich von Ferstel, 1871. Europe's first museum dedicated to applied arts and craft.",
    "The foundation institution of the Wiener Werkstätte and the design lineage of the Vienna Secession.",
  ],
  fun_fact: nil,
  sequence_number: 13,
  riddle: "A museum that refused the academy's hierarchy: chairs, lamps and posters get the same plinth as paintings. Built when 'design' was still a word that didn't quite exist.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Plinth of Chairs"
end

loc = Location.find_or_create_by!(name: "Johann-Strauss-Denkmal · Stadtpark", city: "Vienna") do |location|
  lat: "48.2039131",
  long: "16.3791303",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "Vienna's most-photographed monument, cast in twenty-four-carat gold.",
    "Edmund Hellmer, 1921. He plays his violin for nobody.",
    "In the Stadtpark, on the eastern Ring.",
  ],
  fun_fact: nil,
  sequence_number: 14,
  riddle: "Vienna's most-photographed man stands in a park, playing his violin for nobody. He is cast in twenty-four-carat gold.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "Twenty-Four Carats"
end

loc = Location.find_or_create_by!(name: "Stadtpark · Wienflussportal", city: "Vienna") do |location|
  lat: "48.2027943",
  long: "16.3787555",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "The southern edge of Vienna's first public park, where a man-made tunnel mouth opens beside the lake.",
    "Friedrich Ohmann and Josef Hackhofer, 1903. A Donauweibchen statue presides over the portal.",
    "A Jugendstil arch on the river-cover, a short walk south of the gilded composer in the same park.",
  ],
  fun_fact: nil,
  sequence_number: 15,
  riddle: "At the edge of the park, an arch covers the place where a river ducks under the city. It will not surface again until it is almost at the Danube.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "Where the River Goes Down"
end

loc = Location.find_or_create_by!(name: "Hundertwasserhaus", city: "Vienna") do |location|
  lat: "48.2073852",
  long: "16.3943079",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "An architect renamed himself after rain — 'hundred-water.'",
    "A tree lives on its third storey.",
    "Onion domes on a council block, in Landstraße.",
  ],
  fun_fact: nil,
  sequence_number: 16,
  riddle: "A painter believed straight lines were the devil's. He was given a public housing block and proved it.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Devil's Lines"
end

loc = Location.find_or_create_by!(name: "KunstHaus Wien", city: "Vienna") do |location|
  lat: "48.2111885",
  long: "16.3934482",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "Three blocks from the painter's most famous building, his second one.",
    "A former bentwood-chair factory.",
    "In the 3rd district, between the Hundertwasserhaus and the Donaukanal.",
  ],
  fun_fact: nil,
  sequence_number: 17,
  riddle: "Round the corner from the painter's most famous building, the same fevered hand reshaped an old factory.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Painter's Second"
end

loc = Location.find_or_create_by!(name: "Copa Beach · Donauinsel", city: "Vienna") do |location|
  lat: "48.2312384",
  long: "16.4107366",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "On the Donauinsel, the 21-km-long artificial flood-control island that splits the Danube.",
    "Built 1972–1988 as flood protection; the recreation use was an afterthought that became the main one.",
    "Accessible by U1 to the island station; busy on summer weekends, all but empty in winter.",
  ],
  fun_fact: nil,
  sequence_number: 18,
  riddle: "An artificial island built in the 1970s to control floods became, by accident, the largest swimming beach in the city. In summer it has the second-most visitors of anywhere in Vienna. Most of them are wearing very little.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Accidental Beach"
end

loc = Location.find_or_create_by!(name: "Jane-Jacobs-Steg · Seestadt Aspern", city: "Vienna") do |location|
  lat: "48.2266119",
  long: "16.5081662",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt1, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "In Seestadt Aspern, the 22nd district — built on a former airfield, served by the eastern terminus of the U2.",
    "Jane Jacobs (1916–2006), American-Canadian urbanist whose Death and Life of Great American Cities argued against the modernist demolition of old neighbourhoods.",
    "Cross the bridge to reach the lake at the heart of the city's newest district — a few minutes' walk from the U2 terminus.",
  ],
  fun_fact: nil,
  sequence_number: 19,
  riddle: "A footbridge across an artificial lake in a city that did not exist twenty years ago. Named for an American who fought urban-planning officials her whole life. The buildings around the lake are named after women like her.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Urbanist's Bridge"
end

# --- Vienna Reinvented (20 stops) ---
loc = Location.find_or_create_by!(name: "Schönbrunn · Schloss", city: "Vienna") do |location|
  lat: "48.1860829",
  long: "16.3126699",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "At the foot of a hill in the far western reaches of the city, fronting an enormous gravelled courtyard.",
    "Maria Theresia held court here; Karl I abdicated here in 1918.",
    "The yellow palace front, seen from the great gravelled forecourt called the Ehrenhof.",
  ],
  fun_fact: nil,
  sequence_number: 1,
  riddle: "Twelve hundred rooms behind the yellow front. An empress raised sixteen children here, and one of her descendants signed an empire away in a room upstairs.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Yellow Court"
end

loc = Location.find_or_create_by!(name: "Schönbrunn · Römische Ruine", city: "Vienna") do |location|
  lat: "48.1808705",
  long: "16.3133575",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "East side of the palace gardens, between the maze and the Neptunbrunnen.",
    "Johann Ferdinand Hetzendorf von Hohenberg, 1778. A Romantic folly built to look like the Roman Forum.",
    "An eighteenth-century Romantic folly built to look like ancient ruins — in the eastern half of the palace gardens.",
  ],
  fun_fact: nil,
  sequence_number: 2,
  riddle: "An imperial architect built ancient ruins from scratch — broken arches, fallen pillars, weathered stones. Two hundred and fifty years later, they look authentically Roman. They never were.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Fake Ruin"
end

loc = Location.find_or_create_by!(name: "Schönbrunn · Gloriette", city: "Vienna") do |location|
  lat: "48.1784262",
  long: "16.308735",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "On the hill above the Schloss — climb the gravel paths to the top.",
    "Maria Theresia commissioned it 1775 to mark the Habsburg recovery after the Seven Years' War.",
    "The hilltop colonnade with the panoramic view back over the city.",
  ],
  fun_fact: nil,
  sequence_number: 3,
  riddle: "Up the hill behind the yellow palace, a colonnade of arches marks a battle the empress called a victory. The view from the roof is the only place in the city where everything the empire built can be seen at once.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Triumph"
end

loc = Location.find_or_create_by!(name: "Technisches Museum Wien", city: "Vienna") do |location|
  lat: "48.1904868",
  long: "16.317779",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "On Mariahilfer Straße in the 14th district, the long western axis out of the city.",
    "1909. Hans Schneider's purpose-built museum of technology, founded under Emperor Franz Joseph.",
    "Founded under Emperor Franz Joseph; inside, the first electric power station, the first telephone exchange, and the country's earliest computer.",
  ],
  fun_fact: nil,
  sequence_number: 4,
  riddle: "The largest museum building in the city, raised in 1909 to celebrate machines instead of monarchs. Inside, the first electric power station, the first telephone exchange, and Vienna's earliest computer.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The First Telephone"
end

loc = Location.find_or_create_by!(name: "Haus des Meeres", city: "Vienna") do |location|
  lat: "48.197907",
  long: "16.3528202",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "In Esterházypark, a small public garden in the 6th district off Mariahilfer Straße.",
    "The Leitturm of the Esterházypark flak tower pair, converted into a public aquarium in 1957.",
    "Exterior climbing wall up one side; panoramic café on the roof. Visible from any high point in the 6th district.",
  ],
  fun_fact: nil,
  sequence_number: 5,
  riddle: "Another five-metre-walled concrete monolith from 1944, this one in the 6th district. It cannot be demolished either. So they filled it with water and sharks.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Other Cube"
end

loc = Location.find_or_create_by!(name: "Mozart-Denkmal · Burggarten", city: "Vienna") do |location|
  lat: "48.2044883",
  long: "16.3659087",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 150,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "A composer in marble, in the Hofburg's private garden.",
    "The flowerbed at his feet is a treble clef.",
    "Square, compass, and sun — the symbols of his most famous opera.",
  ],
  fun_fact: nil,
  sequence_number: 6,
  riddle: "Behind an imperial garden gate, a man stands in marble. The flowers at his feet spell music; the carvings on his plinth spell a secret society.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "Square and Compass"
end

loc = Location.find_or_create_by!(name: "Schmetterlinghaus", city: "Vienna") do |location|
  lat: "48.205669",
  long: "16.3662895",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "In the small palace garden between the imperial residence and the Ringstraße — a tall glass house at the south end.",
    "Friedrich Ohmann + Ludwig Beermann, 1901. Originally a Palmenhaus; the butterfly conservatory was added in 1998.",
    "An iron-and-glass pavilion at the south end of the imperial back garden — exterior view free, butterflies ticketed.",
  ],
  fun_fact: nil,
  sequence_number: 7,
  riddle: "An Art Nouveau pavilion of iron and glass, set in the imperial back garden. Inside, hundreds of tropical butterflies fly free. The architect built it for palms; the butterflies came almost a hundred years later.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "Wings Behind Glass"
end

loc = Location.find_or_create_by!(name: "Schweizertor · Hofburg", city: "Vienna") do |location|
  lat: "48.2066",
  long: "16.36546",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "A Renaissance gate, painted in Habsburg red and white, deep inside the imperial palace's inner courtyard.",
    "Five vowels in sequence — the personal motto of Frederick III, decoded a dozen ways and never settled.",
    "Pass through the Michaelertrakt; the gate is on the western wall of the Innerer Burghof, just before the Schatzkammer entrance.",
  ],
  fun_fact: nil,
  sequence_number: 8,
  riddle: "An emperor signed everything with five letters: A · E · I · O · U. Six centuries later, nobody agrees what they meant. The painted gate at the heart of the imperial palace bears them above its arch.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Five Letters"
end

loc = Location.find_or_create_by!(name: "Vindobona ruins · Michaelerplatz", city: "Vienna") do |location|
  lat: "48.207961",
  long: "16.3665395",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "A glass-walled circle set into the pavement of an old square.",
    "Soldiers slept here when Vienna had a Latin name.",
    "Excavated during U-Bahn construction. Look for the cobbles that open downward.",
  ],
  fun_fact: nil,
  sequence_number: 9,
  riddle: "On a Habsburg square, the cobbles open into a glass pit. Two thousand years of soldiers are stacked between you and them.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "Beneath the Cobbles"
end

loc = Location.find_or_create_by!(name: "Looshaus", city: "Vienna") do |location|
  lat: "48.2084285",
  long: "16.3667315",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 80,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "An emperor closed his curtains so he wouldn't have to see it from the palace.",
    "Its architect wrote the essay 'Ornament and Crime' the same year.",
    "On a small square in the inner city, named for an archangel.",
  ],
  fun_fact: nil,
  sequence_number: 10,
  riddle: "An emperor drew his curtains. Find what he could not bear to see.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Drawn Curtains"
end

loc = Location.find_or_create_by!(name: "Stephansdom · Türkenkanonenkugel", city: "Vienna") do |location|
  lat: "48.2084538",
  long: "16.3734842",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 80,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "Look up — the south buttress of the city's tallest church, just below the eaves.",
    "Iron, smooth, the size of a melon. A small plaque dates it to the year of the second siege.",
    "On the south face of the cathedral whose spire dominates the inner-city skyline.",
  ],
  fun_fact: nil,
  sequence_number: 11,
  riddle: "A dark sphere is buried high in the cathedral's south wall. It was fired in 1683. Nobody removed it.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Souvenir"
end

loc = Location.find_or_create_by!(name: "Freyung · Austria-Brunnen", city: "Vienna") do |location|
  lat: "48.2116796",
  long: "16.3657016",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "An inner-city square that owes its name to a medieval right of asylum, granted by Irish-Scottish monks.",
    "Four bronze allegorical women on a fountain plinth: Danube, Vistula, Po, Elbe.",
    "Between Herrengasse and Schottentor, at the foot of the oldest monastery in Vienna.",
  ],
  fun_fact: nil,
  sequence_number: 12,
  riddle: "A square named for sanctuary. At its centre, four bronze women pour the empire's rivers — name them and you've named what's been lost.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Four Rivers"
end

loc = Location.find_or_create_by!(name: "Mölker Bastei · Pasqualatihaus", city: "Vienna") do |location|
  lat: "48.21251",
  long: "16.3623699",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "A scrap of the wall that broke the 1683 siege still stands above the modern street.",
    "Climb the stone staircase next to the University.",
    "Beethoven lived in the house on top while writing the Eroica.",
  ],
  fun_fact: nil,
  sequence_number: 13,
  riddle: "The last stone of the broken wall. A deaf man wrote a symphony on top — and crossed out the name he had dedicated it to.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Last Stone"
end

loc = Location.find_or_create_by!(name: "Theseustempel · Volksgarten", city: "Vienna") do |location|
  lat: "48.2083895",
  long: "16.3617318",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "A Greek temple built to hold a single Canova sculpture; the sculpture moved to a museum.",
    "One-fifth scale of the Hephaisteion in Athens.",
    "In the rose garden between the Hofburg and the Burgtheater.",
  ],
  fun_fact: nil,
  sequence_number: 14,
  riddle: "A Greek temple in an imperial garden. Built to hold one statue. The statue moved. The temple stayed.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Hero Who Left"
end

loc = Location.find_or_create_by!(name: "Strudlhofstiege", city: "Vienna") do |location|
  lat: "48.2222819",
  long: "16.3577826",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "A Jugendstil staircase, built in 1910 for a forgotten Baroque painter.",
    "Heimito von Doderer made it the spine of a 900-page novel in 1951.",
    "In Alsergrund, between Liechtensteinstraße and the street it's named after.",
  ],
  fun_fact: nil,
  sequence_number: 15,
  riddle: "A staircase built for a painter no one remembers. A novelist took its name and made it famous — but not for the painter.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Forgotten Painter"
end

loc = Location.find_or_create_by!(name: "Garten-Palais Liechtenstein", city: "Vienna") do |location|
  lat: "48.2226927",
  long: "16.3595988",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "In Alsergrund, the 9th district, with a wrought-iron gate on Fürstengasse.",
    "The Liechtensteins — princes whose territory between Switzerland and Austria measures only 160 km².",
    "A princely garden palace in Alsergrund, holding the family's Rubens, Raphael, and Canova marbles.",
  ],
  fun_fact: nil,
  sequence_number: 16,
  riddle: "A Baroque garden palace in the 9th district, owned for three hundred years by the family with the smallest sovereign country in Europe. The art inside is one of the largest private collections on the continent; the garden outside costs nothing to enter.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Smallest Country"
end

loc = Location.find_or_create_by!(name: "Denkmal der ukrainischen Kosaken · Türkenschanzpark", city: "Vienna") do |location|
  lat: "48.2357141",
  long: "16.3340266",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "In Türkenschanzpark in the 18th district — built on the actual 1683 Ottoman gun emplacement.",
    "The Ukrainian Cossacks under hetmans Kunicki and Mohyla, fighting under King Jan III Sobieski's command.",
    "The 1990s monument to the Ukrainian Cossack defenders of the 1683 siege.",
  ],
  fun_fact: nil,
  sequence_number: 17,
  riddle: "In a hilltop park named for an Ottoman artillery position, a granite obelisk honours the cavalrymen who broke the 1683 siege from the north. Most Viennese don't know they came at all.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Forgotten Allies"
end

loc = Location.find_or_create_by!(name: "Setagayapark", city: "Vienna") do |location|
  lat: "48.2453326",
  long: "16.356237",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "On the slopes above the Donaukanal, in the 19th district between Heiligenstadt and Hohe Warte.",
    "A reciprocal sister-city gift from Setagaya, one of Tokyo's special wards.",
    "The only Japanese garden in the city, free to enter from dawn to dusk.",
  ],
  fun_fact: nil,
  sequence_number: 18,
  riddle: "A Japanese garden in the 19th district, gifted by Tokyo's Setagaya ward in 1992. The stones came from Japan. The cherry trees came from Japan. Even the wooden bridge was built by Japanese carpenters flown in for the work.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Tokyo Gift"
end

loc = Location.find_or_create_by!(name: "Augarten Flak Tower", city: "Vienna") do |location|
  lat: "48.2259747",
  long: "16.3735279",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 150,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "In the Augarten park, the 2nd district's grand Baroque public garden.",
    "Concrete walls so thick no peacetime explosive charge can safely dismantle them.",
    "The larger of the pair, deeper inside the Baroque park than the other.",
  ],
  fun_fact: nil,
  sequence_number: 19,
  riddle: "Fifty-five metres of solid concrete, walls five metres thick, sitting in a Baroque public garden. They cannot demolish it — the explosion would take half the neighbourhood. So it stays, ringed by rose beds, an architectural ghost.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Indestructible Cube"
end

loc = Location.find_or_create_by!(name: "Wiener Riesenrad · Prater", city: "Vienna") do |location|
  lat: "48.2167463",
  long: "16.3959139",
  description: nil,
  reasoning: nil,
  country: "Austria",
  difficulty: "challenging",
  unlock_radius: 50,
  verification_state: "ai_generated"
end
Clue.find_or_create_by!(hunt: hunt2, location: loc) do |clue|
  description: nil,
  difficulty: "challenging",
  reasoning: nil,
  hints: [
    "At the western edge of a vast public park, near Praterstern.",
    "1897. Built for the Emperor Franz Joseph's golden jubilee.",
    "The Third Man film. The cuckoo-clock speech. Welles on a slow turn above Vienna.",
  ],
  fun_fact: nil,
  sequence_number: 20,
  riddle: "A great iron wheel turns slowly at the edge of the chestnut wood. Orson Welles rode it once, and said the people below it looked like dots. Most of its original cars are gone; the survivors still circle, sixty-five metres up.",
  story_bridge: nil,
  bonus_task: nil,
  image_url: nil,
  proximity_feedback: true,
  title: "The Wheel"
end

puts "Seeded #{Hunt.count} hunts, #{Location.count} locations, #{Clue.count} clues"
