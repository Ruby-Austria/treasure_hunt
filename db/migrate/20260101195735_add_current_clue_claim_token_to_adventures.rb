class AddCurrentClueClaimTokenToAdventures < ActiveRecord::Migration[8.1]
  def change
    add_column :adventures, :current_clue_claim_token, :string
    add_column :adventures, :current_clue_claim_token_expires_at, :datetime
  end
end
