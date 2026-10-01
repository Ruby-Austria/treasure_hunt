class ClaimClueService
  attr_reader :adventure, :error

  def initialize(adventure:, claim_token: nil, force: false)
    @adventure = adventure
    @claim_token = claim_token
    @force = force
    @error = nil
    @success = false
  end

  def call
    return self unless validate_claim

    @adventure.with_lock do
      # Re-validate under lock to prevent race conditions
      unless @force
        if @adventure.current_clue_claim_token != @claim_token
          @error = "Invalid claim token"
          return self
        end
      end

      if @adventure.solve_current_clue!
        # Clear the claim token after successful claim
        @adventure.update!(
          current_clue_claim_token: nil,
          current_clue_claim_token_expires_at: nil
        )
        propagate_to_team
        @success = true
      else
        @error = "Could not claim clue"
      end
    end
    self
  end

  def success?
    @success
  end

  private

  def propagate_to_team
    team = @adventure.user.team
    return unless team

    team.members.where.not(id: @adventure.user_id).find_each do |member|
      teammate_adventure = member.adventures.find_by(hunt_id: @adventure.hunt_id, status: :in_progress)
      next unless teammate_adventure

      solved_clue_id = @adventure.solved_clue_ids.last
      next if teammate_adventure.solved_clue_ids.include?(solved_clue_id)

      teammate_adventure.solved_clue_ids << solved_clue_id
      next_clue_id = (teammate_adventure.hunt.clues.order(:id).pluck(:id) - teammate_adventure.solved_clue_ids).first

      if next_clue_id
        teammate_adventure.update!(current_clue_id: next_clue_id)
      else
        teammate_adventure.update!(current_clue_id: nil, status: :completed)
      end
    end
  end

  def validate_claim
    # If force is true, skip all validation
    return true if @force

    # Check if current clue exists
    unless @adventure.current_clue
      @error = "No clue to solve"
      return false
    end

    # Validate claim token
    unless @claim_token.present?
      @error = "Claim token is required"
      return false
    end

    # Clean up expired tokens first
    if @adventure.current_clue_claim_token_expires_at.present? &&
       @adventure.current_clue_claim_token_expires_at < Time.current
      @adventure.update!(
        current_clue_claim_token: nil,
        current_clue_claim_token_expires_at: nil
      )
      @error = "Claim token has expired"
      return false
    end

    # Check if token matches
    if @adventure.current_clue_claim_token != @claim_token
      @error = "Invalid claim token"
      return false
    end

    true
  end
end
