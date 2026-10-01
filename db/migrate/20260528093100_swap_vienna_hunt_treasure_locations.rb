class SwapViennaHuntTreasureLocations < ActiveRecord::Migration[8.1]
  TREASURE_LOCATIONS = {
    "The Hidden City"   => "Wangari-Maathai-Platz 3, 1220 Wien, Austria",
    "Vienna Reinvented" => "Nordbahnstraße 51, 1020 Wien, Austria"
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
    raise ActiveRecord::IrreversibleMigration
  end
end
