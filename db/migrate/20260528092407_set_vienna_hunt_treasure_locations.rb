class SetViennaHuntTreasureLocations < ActiveRecord::Migration[8.1]
  TREASURE_LOCATIONS = {
    "The Hidden City"   => "Nordbahnstraße 51, 1020 Wien, Austria",
    "Vienna Reinvented" => "Wangari-Maathai-Platz 3, 1220 Wien, Austria"
  }

  def up
    TREASURE_LOCATIONS.each do |hunt_name, address|
      hunt = Hunt.find_by(name: hunt_name)
      if hunt
        hunt.update!(treasure_location: address)
        say "#{hunt_name} → #{address}"
      else
        say "Skipping #{hunt_name} — hunt not present"
      end
    end
  end

  def down
    TREASURE_LOCATIONS.each_key do |hunt_name|
      hunt = Hunt.find_by(name: hunt_name)
      hunt&.update!(treasure_location: nil)
    end
  end
end
