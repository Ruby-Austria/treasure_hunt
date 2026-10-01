# Widen Location.lat / Location.long from decimal(10,7) to decimal(15,12)
# so paste-from-Google strings (often 13–15 fractional digits) survive
# round-tripping without truncation. Has no gameplay effect — phone GPS
# can't produce anywhere near this precision — but removes the audit
# friction of "the DB chopped off the digits I pasted."
class WidenLocationCoordinates < ActiveRecord::Migration[8.1]
  def up
    change_column :locations, :lat, :decimal, precision: 15, scale: 12, null: false
    change_column :locations, :long, :decimal, precision: 15, scale: 12, null: false
  end

  def down
    change_column :locations, :lat, :decimal, precision: 10, scale: 7, null: false
    change_column :locations, :long, :decimal, precision: 10, scale: 7, null: false
  end
end
