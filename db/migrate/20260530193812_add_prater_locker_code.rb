# Set the actual MyFlexBox locker code for the Praterstern hunt
# (Vienna Reinvented, chest at Nordbahnstraße 51).
class AddPraterLockerCode < ActiveRecord::Migration[8.1]
  HUNT_NAME = "Vienna Reinvented"
  CODE      = "87205150"

  TREASURE_HINT =
    "At the address, look for a MyFlexBox parcel locker. Enter the code " \
    "#{CODE} to open it. If it doesn't work, reach out to Muhamed with " \
    "the phrase \"I need the secret key\"."

  def up
    hunt = Hunt.find_by(name: HUNT_NAME)
    return say "Skipping — hunt #{HUNT_NAME.inspect} not present" unless hunt

    hunt.update!(
      treasure_access_code: CODE,
      treasure_hint:        TREASURE_HINT
    )
    say "Set MyFlexBox code on #{HUNT_NAME}."
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
