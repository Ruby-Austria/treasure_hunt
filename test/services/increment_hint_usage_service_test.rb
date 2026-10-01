require "test_helper"

class IncrementHintUsageServiceTest < ActiveSupport::TestCase
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
      solved_clue_ids: [],
      hints_used: 0,
      revealed_hints: []
    )

    # Set up hints for the current clue
    @adventure.reload
    current_clue = @adventure.current_clue
    current_clue.update!(hints: [ "Hint 1", "Hint 2", "Hint 3" ])
  end

  test "should successfully reveal a random hint" do
    service = IncrementHintUsageService.new(adventure: @adventure).call

    assert service.success?
    assert_nil service.error
    assert_not_nil service.hint
    assert_includes [ "Hint 1", "Hint 2", "Hint 3" ], service.hint
    assert_equal 1, service.hints_used
    assert_includes service.revealed_hints, service.hint
    assert_not_nil service.next_hint_available_at

    @adventure.reload
    assert_equal 1, @adventure.hints_used
    assert_includes @adventure.revealed_hints, service.hint
    assert_not_nil @adventure.last_hint_revealed_at
  end

  test "should return error when no current clue exists" do
    # Mark all clues as solved and clear current_clue
    @adventure.update!(solved_clue_ids: [ @clue1.id, @clue2.id ], status: :completed)
    @adventure.update_column(:current_clue_id, nil)

    service = IncrementHintUsageService.new(adventure: @adventure).call

    assert_not service.success?
    assert_equal "No current clue available", service.error
    assert_nil service.hint
  end

  test "should return error when no hints available for clue" do
    @adventure.reload
    @adventure.current_clue.update!(hints: [])

    service = IncrementHintUsageService.new(adventure: @adventure).call

    assert_not service.success?
    assert_equal "No hints available for this clue", service.error
    assert_nil service.hint
  end

  test "should return success when all hints have been revealed" do
    # Reveal all hints
    @adventure.update!(
      revealed_hints: [ "Hint 1", "Hint 2", "Hint 3" ],
      hints_used: 3
    )

    service = IncrementHintUsageService.new(adventure: @adventure).call

    assert service.success?
    assert_nil service.error
    assert_nil service.hint
    assert_equal 3, service.hints_used
    assert_equal [ "Hint 1", "Hint 2", "Hint 3" ], service.revealed_hints
  end

  test "should enforce 30-minute cooldown between hint reveals" do
    # Set last hint revealed to 10 minutes ago (within 30-min cooldown)
    @adventure.update!(
      last_hint_revealed_at: 10.minutes.ago,
      hints_used: 1,
      revealed_hints: [ "Hint 1" ]
    )

    service = IncrementHintUsageService.new(adventure: @adventure).call

    assert_not service.success?
    assert_equal "Please wait before revealing another hint", service.error
    assert_not_nil service.cooldown_remaining
    assert_not_nil service.cooldown_remaining_minutes
    assert service.cooldown_remaining > 0
    assert service.cooldown_remaining_minutes > 0
    assert_not_nil service.next_hint_available_at

    # Verify no new hint was revealed
    @adventure.reload
    assert_equal 1, @adventure.hints_used
    assert_equal [ "Hint 1" ], @adventure.revealed_hints
  end

  test "should allow hint reveal after cooldown period" do
    # Set last hint revealed to 35 minutes ago (past 30-min cooldown)
    @adventure.update!(
      last_hint_revealed_at: 35.minutes.ago,
      hints_used: 1,
      revealed_hints: [ "Hint 1" ]
    )

    service = IncrementHintUsageService.new(adventure: @adventure).call

    assert service.success?
    assert_nil service.error
    assert_not_nil service.hint
    assert_includes [ "Hint 2", "Hint 3" ], service.hint
    assert_equal 2, service.hints_used
    assert_includes service.revealed_hints, service.hint
  end

  test "should allow hint reveal when no previous hint was revealed" do
    # No last_hint_revealed_at set
    @adventure.update!(
      last_hint_revealed_at: nil,
      hints_used: 0,
      revealed_hints: []
    )

    service = IncrementHintUsageService.new(adventure: @adventure).call

    assert service.success?
    assert_not_nil service.hint
    assert_equal 1, service.hints_used
  end

  test "should increment hints_used counter" do
    initial_hints_used = @adventure.hints_used

    service = IncrementHintUsageService.new(adventure: @adventure).call

    assert service.success?
    assert_equal initial_hints_used + 1, service.hints_used
    @adventure.reload
    assert_equal initial_hints_used + 1, @adventure.hints_used
  end

  test "should add revealed hint to revealed_hints array" do
    initial_revealed = @adventure.revealed_hints.dup

    service = IncrementHintUsageService.new(adventure: @adventure).call

    assert service.success?
    assert_equal initial_revealed.length + 1, service.revealed_hints.length
    assert_includes service.revealed_hints, service.hint

    @adventure.reload
    assert_includes @adventure.revealed_hints, service.hint
  end

  test "should update last_hint_revealed_at timestamp" do
    old_timestamp = @adventure.last_hint_revealed_at

    service = IncrementHintUsageService.new(adventure: @adventure).call

    assert service.success?
    @adventure.reload
    assert_not_nil @adventure.last_hint_revealed_at
    assert @adventure.last_hint_revealed_at > old_timestamp if old_timestamp
  end

  test "should set next_hint_available_at to 30 minutes from now" do
    service = IncrementHintUsageService.new(adventure: @adventure).call

    assert service.success?
    assert_not_nil service.next_hint_available_at

    expected_time = Time.current + 30.minutes
    time_difference = (service.next_hint_available_at - expected_time).abs

    # Allow 5 seconds difference for execution time
    assert time_difference < 5.seconds
  end

  test "should return self from call method" do
    service = IncrementHintUsageService.new(adventure: @adventure)

    result = service.call

    assert_equal service, result
    assert_respond_to result, :success?
    assert_respond_to result, :error
    assert_respond_to result, :hint
    assert_respond_to result, :hints_used
    assert_respond_to result, :revealed_hints
  end

  test "should have access to adventure after call" do
    service = IncrementHintUsageService.new(adventure: @adventure).call

    assert_equal @adventure, service.adventure
  end

  test "should reveal different hints on multiple calls" do
    # First call
    service1 = IncrementHintUsageService.new(adventure: @adventure).call
    assert service1.success?
    first_hint = service1.hint

    # Bypass cooldown
    @adventure.update!(
      last_hint_revealed_at: 35.minutes.ago,
      revealed_hints: [ first_hint ],
      hints_used: 1
    )

    # Second call
    service2 = IncrementHintUsageService.new(adventure: @adventure).call
    assert service2.success?
    second_hint = service2.hint

    # Should be different hints
    assert_not_equal first_hint, second_hint
  end

  test "should handle cooldown calculation correctly" do
    # Set last hint to 15 minutes ago (15 minutes remaining)
    @adventure.update!(
      last_hint_revealed_at: 15.minutes.ago,
      hints_used: 1,
      revealed_hints: [ "Hint 1" ]
    )

    service = IncrementHintUsageService.new(adventure: @adventure).call

    assert_not service.success?
    assert_not_nil service.cooldown_remaining
    assert_not_nil service.cooldown_remaining_minutes

    # Should be approximately 15 minutes remaining (allow some variance)
    assert service.cooldown_remaining_minutes > 13
    assert service.cooldown_remaining_minutes < 17
  end

  test "should not reveal already revealed hints" do
    # Reveal first hint
    @adventure.update!(
      revealed_hints: [ "Hint 1" ],
      hints_used: 1,
      last_hint_revealed_at: 35.minutes.ago
    )

    service = IncrementHintUsageService.new(adventure: @adventure).call

    assert service.success?
    assert_not_nil service.hint
    assert_not_equal "Hint 1", service.hint
    assert_includes [ "Hint 2", "Hint 3" ], service.hint
  end

  test "should handle empty hints array gracefully" do
    @adventure.reload
    @adventure.current_clue.update!(hints: [])

    service = IncrementHintUsageService.new(adventure: @adventure).call

    assert_not service.success?
    assert_equal "No hints available for this clue", service.error
  end

  test "should handle empty revealed_hints array" do
    @adventure.update!(revealed_hints: [])

    service = IncrementHintUsageService.new(adventure: @adventure).call

    assert service.success?
    assert_not_nil service.hint
    assert_equal 1, service.revealed_hints.length
  end
end
