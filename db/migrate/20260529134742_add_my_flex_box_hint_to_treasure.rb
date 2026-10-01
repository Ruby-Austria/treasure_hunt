# Extend the treasure_hint on both hunts to mention the MyFlexBox
# locker where the chest is stored.
class AddMyFlexBoxHintToTreasure < ActiveRecord::Migration[8.1]
  TREASURE_HINT =
    "At the address, look for a MyFlexBox parcel locker. Reach out to Muhamed " \
    "with the phrase \"I need the secret key\" — he'll provide one to open it."

  HUNTS = [ "The Hidden City", "Vienna Reinvented" ]

  def up
    HUNTS.each do |name|
      hunt = Hunt.find_by(name: name)
      next unless hunt

      hunt.update!(treasure_hint: TREASURE_HINT)
      say "Updated treasure_hint on #{name}."
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
