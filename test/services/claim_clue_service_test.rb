require "test_helper"

class ClaimClueServiceTest < ActiveSupport::TestCase
  def setup
    @user = users(:regular_user)
    @hunt = hunts(:two)
    @hunt.update!(status: :approved)

    # Ensure hunt has clues
    @location = locations(:one)
    @location2 = locations(:two)
    @clue1 = Clue.find_or_create_by!(hunt: @hunt, location: @location) { |c| c.difficulty = :easy }
    @clue2 = Clue.find_or_create_by!(hunt: @hunt, location: @location2) { |c| c.difficulty = :moderate }

    # Clear any existing in_progress adventures for this user/hunt
    @user.adventures.where(hunt: @hunt, status: :in_progress).destroy_all

    # Create an adventure with unsolved clues
    @adventure = Adventure.create!(
      user: @user,
      hunt: @hunt,
      status: :in_progress,
      solved_clue_ids: []
    )
    @adventure.reload

    @valid_token = SecureRandom.hex(32)
    @adventure.update!(
      current_clue_claim_token: @valid_token,
      current_clue_claim_token_expires_at: 2.minutes.from_now
    )
  end

  test "should successfully claim clue with valid token" do
    current_clue_id = @adventure.current_clue_id
    service = ClaimClueService.new(
      adventure: @adventure,
      claim_token: @valid_token,
      force: false
    ).call

    assert service.success?
    assert_nil service.error
    assert_includes @adventure.reload.solved_clue_ids, current_clue_id
    assert_nil @adventure.current_clue_claim_token
    assert_nil @adventure.current_clue_claim_token_expires_at
  end

  test "should return error when claim token is missing" do
    service = ClaimClueService.new(
      adventure: @adventure,
      claim_token: nil,
      force: false
    ).call

    assert_not service.success?
    assert_equal "Claim token is required", service.error
  end

  test "should return error when claim token is empty string" do
    service = ClaimClueService.new(
      adventure: @adventure,
      claim_token: "",
      force: false
    ).call

    assert_not service.success?
    assert_equal "Claim token is required", service.error
  end

  test "should return error when claim token is invalid" do
    service = ClaimClueService.new(
      adventure: @adventure,
      claim_token: "invalid_token",
      force: false
    ).call

    assert_not service.success?
    assert_equal "Invalid claim token", service.error
  end

  test "should return error when claim token has expired" do
    @adventure.update!(
      current_clue_claim_token: @valid_token,
      current_clue_claim_token_expires_at: 1.minute.ago
    )

    service = ClaimClueService.new(
      adventure: @adventure,
      claim_token: @valid_token,
      force: false
    ).call

    assert_not service.success?
    assert_equal "Claim token has expired", service.error
    # Token should be cleaned up
    @adventure.reload
    assert_nil @adventure.current_clue_claim_token
    assert_nil @adventure.current_clue_claim_token_expires_at
  end

  test "should return error when no current clue exists" do
    # Mark all clues as solved
    @adventure.update!(solved_clue_ids: [ @clue1.id, @clue2.id ], status: :completed)
    @adventure.update_column(:current_clue_id, nil)

    service = ClaimClueService.new(
      adventure: @adventure,
      claim_token: @valid_token,
      force: false
    ).call

    assert_not service.success?
    assert_equal "No clue to solve", service.error
  end

  test "should successfully force claim without token validation" do
    current_clue_id = @adventure.current_clue_id
    service = ClaimClueService.new(
      adventure: @adventure,
      claim_token: nil,
      force: true
    ).call

    assert service.success?
    assert_nil service.error
    assert_includes @adventure.reload.solved_clue_ids, current_clue_id
    assert_nil @adventure.current_clue_claim_token
    assert_nil @adventure.current_clue_claim_token_expires_at
  end

  test "should successfully force claim even with invalid token" do
    current_clue_id = @adventure.current_clue_id
    service = ClaimClueService.new(
      adventure: @adventure,
      claim_token: "invalid_token",
      force: true
    ).call

    assert service.success?
    assert_nil service.error
    assert_includes @adventure.reload.solved_clue_ids, current_clue_id
  end

  test "should successfully force claim even with expired token" do
    @adventure.update!(
      current_clue_claim_token: @valid_token,
      current_clue_claim_token_expires_at: 1.minute.ago
    )

    current_clue_id = @adventure.current_clue_id
    service = ClaimClueService.new(
      adventure: @adventure,
      claim_token: @valid_token,
      force: true
    ).call

    assert service.success?
    assert_nil service.error
    assert_includes @adventure.reload.solved_clue_ids, current_clue_id
  end

  test "should clear claim token after successful claim" do
    assert_not_nil @adventure.current_clue_claim_token
    assert_not_nil @adventure.current_clue_claim_token_expires_at

    service = ClaimClueService.new(
      adventure: @adventure,
      claim_token: @valid_token,
      force: false
    ).call

    assert service.success?
    @adventure.reload
    assert_nil @adventure.current_clue_claim_token
    assert_nil @adventure.current_clue_claim_token_expires_at
  end

  test "should mark adventure as completed when all clues are solved" do
    # Solve the first clue using solve_current_clue! to properly advance
    @adventure.reload
    @adventure.solve_current_clue!
    @adventure.reload

    assert @adventure.in_progress?
    assert_equal 1, @adventure.solved_clue_ids.count

    # Set up token for the remaining clue
    @adventure.update!(
      current_clue_claim_token: @valid_token,
      current_clue_claim_token_expires_at: 2.minutes.from_now
    )

    service = ClaimClueService.new(
      adventure: @adventure,
      claim_token: @valid_token,
      force: false
    ).call

    assert service.success?
    @adventure.reload
    assert @adventure.completed?
    assert_equal 2, @adventure.solved_clue_ids.count
  end

  test "should return self from call method" do
    service = ClaimClueService.new(
      adventure: @adventure,
      claim_token: @valid_token,
      force: false
    )

    result = service.call

    assert_equal service, result
    assert_respond_to result, :success?
    assert_respond_to result, :error
  end

  test "should have access to adventure after call" do
    service = ClaimClueService.new(
      adventure: @adventure,
      claim_token: @valid_token,
      force: false
    ).call

    assert_equal @adventure, service.adventure
  end

  test "should handle edge case when token expires exactly at current time" do
    @adventure.update!(
      current_clue_claim_token: @valid_token,
      current_clue_claim_token_expires_at: Time.current
    )

    service = ClaimClueService.new(
      adventure: @adventure,
      claim_token: @valid_token,
      force: false
    ).call

    # Should fail because expires_at is <= Time.current
    assert_not service.success?
    assert_equal "Claim token has expired", service.error
  end

  test "should handle multiple sequential claims" do
    # Claim first clue
    first_clue_id = @adventure.current_clue_id
    service1 = ClaimClueService.new(
      adventure: @adventure,
      claim_token: @valid_token,
      force: false
    ).call

    assert service1.success?
    assert_includes @adventure.reload.solved_clue_ids, first_clue_id

    # Set up token for second clue
    new_token = SecureRandom.hex(32)
    @adventure.update!(
      current_clue_claim_token: new_token,
      current_clue_claim_token_expires_at: 2.minutes.from_now
    )

    # Claim second clue
    second_clue_id = @adventure.current_clue_id
    service2 = ClaimClueService.new(
      adventure: @adventure,
      claim_token: new_token,
      force: false
    ).call

    assert service2.success?
    assert_includes @adventure.reload.solved_clue_ids, second_clue_id
    assert @adventure.completed?
  end
end
