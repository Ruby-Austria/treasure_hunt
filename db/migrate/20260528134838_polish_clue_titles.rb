# Replace 6 descriptive titles with cryptic fragments, matching the
# style of "The Wound Trumpets," "The Drawn Curtains," "The Souvenir."
# Touches every Clue pointing at the location (so shared clues update
# in both hunts).
class PolishClueTitles < ActiveRecord::Migration[8.1]
  TITLE_FIXES = {
    "MAK · Stubenring 5"           => "The Plinth of Chairs",
    "Copa Beach · Donauinsel"      => "The Accidental Beach",
    "Technisches Museum Wien"      => "The First Telephone",
    "Garten-Palais Liechtenstein"  => "The Smallest Country",
    "KunstHaus Wien"               => "The Painter's Second",
    "Schmetterlinghaus"            => "Wings Behind Glass"
  }

  def up
    TITLE_FIXES.each do |loc_name, new_title|
      location = Location.find_by(name: loc_name, city: "Vienna")
      next unless location

      clues = Clue.where(location: location).to_a
      clues.each { |c| c.update!(title: new_title) }
      say "Retitled #{clues.size} clue(s) for #{loc_name} → #{new_title.inspect}"
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
