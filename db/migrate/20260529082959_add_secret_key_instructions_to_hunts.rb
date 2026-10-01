# Add the "secret key" instruction to both Vienna hunts:
#
#   - treasure_hint: shown when the player reaches the chest GPS area.
#   - completion_message: shown after completing the final clue.
#
# Both reference Muhamed; he provides the key in person on the passphrase.
class AddSecretKeyInstructionsToHunts < ActiveRecord::Migration[8.1]
  HIDDEN_CITY_COMPLETION =
    "You read what most visitors miss. Now claim the chest — reach out to Muhamed " \
    "with the phrase \"I need the secret key\" and he'll provide one."

  VIENNA_REINVENTED_COMPLETION =
    "You followed the city's quieter rebellion. Claim your reward — reach out to " \
    "Muhamed with the phrase \"I need the secret key\" and he'll provide one."

  TREASURE_HINT =
    "Reach out to Muhamed with the phrase \"I need the secret key\" — he'll provide one."

  def up
    [
      [ "The Hidden City",   HIDDEN_CITY_COMPLETION ],
      [ "Vienna Reinvented", VIENNA_REINVENTED_COMPLETION ]
    ].each do |name, completion|
      hunt = Hunt.find_by(name: name)
      next unless hunt

      hunt.update!(
        completion_message: completion,
        treasure_hint:      TREASURE_HINT
      )
      say "Updated #{name}: treasure_hint + completion_message."
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
