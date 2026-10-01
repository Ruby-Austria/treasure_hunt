class DropPurchases < ActiveRecord::Migration[8.1]
  def up
    drop_table :purchases
  end

  def down
    create_table :purchases do |t|
      t.references :user, null: false, foreign_key: true
      t.references :hunt, null: false, foreign_key: true
      t.integer :amount_cents
      t.integer :status
      t.string :stripe_session_id
      t.string :stripe_payment_intent_id
      t.timestamps
    end

    add_index :purchases, :stripe_session_id, unique: true
    add_index :purchases, :stripe_payment_intent_id, unique: true
    add_index :purchases, [ :user_id, :hunt_id ]
  end
end
