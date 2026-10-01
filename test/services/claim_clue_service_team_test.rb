require "test_helper"

class ClaimClueServiceTeamTest < ActiveSupport::TestCase
  setup do
    @hunt = hunts(:approved_hunt)
    @location = locations(:one)
    @clue1 = Clue.create!(hunt: @hunt, location: @location, description: "First clue", difficulty: :easy)
    @clue2 = Clue.create!(hunt: @hunt, location: Location.create!(name: "Spot 2", city: "Vienna", country: "Austria", lat: 48.2, long: 16.37, difficulty: :easy), description: "Second clue", difficulty: :easy)

    @team = Team.create!(name: "Test Team")
    @user_a = User.create!(email: "a@test.io", password: "password123")
    @user_b = User.create!(email: "b@test.io", password: "password123")
    @team.members << @user_a
    @team.members << @user_b

    @adventure_a = Adventure.create!(user: @user_a, hunt: @hunt, status: :in_progress, current_clue_id: @clue1.id)
    @adventure_b = Adventure.create!(user: @user_b, hunt: @hunt, status: :in_progress, current_clue_id: @clue1.id)
  end

  test "claim propagates to teammate adventures" do
    token = SecureRandom.hex(32)
    @adventure_a.update!(current_clue_claim_token: token, current_clue_claim_token_expires_at: 2.minutes.from_now)

    result = ClaimClueService.new(adventure: @adventure_a, claim_token: token).call
    assert result.success?

    @adventure_b.reload
    assert_includes @adventure_b.solved_clue_ids, @clue1.id
    assert_equal @clue2.id, @adventure_b.current_clue_id
  end

  test "claim completes teammate adventure when last clue solved" do
    # Solve first clue for both
    @adventure_a.update!(solved_clue_ids: [ @clue1.id ], current_clue_id: @clue2.id)
    @adventure_b.update!(solved_clue_ids: [ @clue1.id ], current_clue_id: @clue2.id)

    token = SecureRandom.hex(32)
    @adventure_a.update!(current_clue_claim_token: token, current_clue_claim_token_expires_at: 2.minutes.from_now)

    result = ClaimClueService.new(adventure: @adventure_a, claim_token: token).call
    assert result.success?

    @adventure_b.reload
    assert @adventure_b.completed?
    assert_nil @adventure_b.current_clue_id
  end

  test "claim does not propagate to non-team member" do
    solo_user = User.create!(email: "solo@test.io", password: "password123")
    solo_adventure = Adventure.create!(user: solo_user, hunt: @hunt, status: :in_progress, current_clue_id: @clue1.id)

    token = SecureRandom.hex(32)
    @adventure_a.update!(current_clue_claim_token: token, current_clue_claim_token_expires_at: 2.minutes.from_now)

    ClaimClueService.new(adventure: @adventure_a, claim_token: token).call

    solo_adventure.reload
    assert_not_includes solo_adventure.solved_clue_ids, @clue1.id
    assert_equal @clue1.id, solo_adventure.current_clue_id
  end

  test "claim does not propagate if teammate has no adventure on that hunt" do
    # user_b has no adventure on this hunt
    @adventure_b.destroy

    token = SecureRandom.hex(32)
    @adventure_a.update!(current_clue_claim_token: token, current_clue_claim_token_expires_at: 2.minutes.from_now)

    result = ClaimClueService.new(adventure: @adventure_a, claim_token: token).call
    assert result.success?
    # No error, just no propagation
  end
end
