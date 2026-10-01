# Drop the Donaukanal Hundertwasser-Promenade clue from The Hidden
# City. Participants were spending too long hunting a 400 m wall
# stretch that doesn't reveal itself well on any single GPS pin.
# Hunt 1 shrinks from 20 to 19 stops; downstream sequence_numbers
# shift up by one.
#
# The Location row itself is left alone (cheap, may be reused later).
class RemoveDonaukanalGraffitiStop < ActiveRecord::Migration[8.1]
  HUNT_NAME = "The Hidden City"
  LOCATION_NAME = "Donaukanal Hundertwasser-Promenade"

  def up
    hunt = Hunt.find_by(name: HUNT_NAME)
    return say "Skipping — hunt not present" unless hunt

    loc = Location.find_by(name: LOCATION_NAME, city: "Vienna")
    return say "Skipping — location not present" unless loc

    clue = hunt.clues.find_by(location: loc)
    return say "Skipping — clue already absent" unless clue

    # Auto-advance any in-progress adventure currently parked on this
    # clue. Setting current_clue_id to nil lets Adventure#ensure_current_clue!
    # pick the next available clue on the player's next visit.
    stuck = Adventure.where(current_clue_id: clue.id)
    if stuck.any?
      stuck.update_all(
        current_clue_id: nil,
        current_clue_claim_token: nil,
        current_clue_claim_token_expires_at: nil
      )
      say "Advanced #{stuck.count} in-progress adventure(s) off the soon-to-be-removed clue."
    end

    clue.destroy!

    Clue.transaction do
      remaining = hunt.clues.order(:sequence_number).to_a
      remaining.each_with_index do |c, idx|
        c.update_columns(sequence_number: -(idx + 1)) # park in negative space
      end
      remaining.each_with_index do |c, idx|
        c.update_columns(sequence_number: idx + 1)
      end
    end

    say "Removed #{LOCATION_NAME} from #{HUNT_NAME}. Hunt now has #{hunt.clues.count} stops."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
