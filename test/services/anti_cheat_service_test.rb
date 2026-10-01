require "test_helper"

class AntiCheatServiceTest < ActiveSupport::TestCase
  def setup
    @user = users(:regular_user)
    @adventure = adventures(:one)
    @lat = 37.7749
    @long = -122.4194
  end

  test "allows legitimate check with no prior history" do
    result = AntiCheatService.new(
      adventure: @adventure, user: @user,
      latitude: @lat, longitude: @long
    ).call

    assert result.ok?
    assert_nil result.error
  end

  test "records check coordinates after successful call" do
    AntiCheatService.new(
      adventure: @adventure, user: @user,
      latitude: @lat, longitude: @long
    ).call

    @adventure.reload
    assert_equal @lat, @adventure.last_check_lat.to_f
    assert_equal @long, @adventure.last_check_long.to_f
    assert_not_nil @adventure.last_check_at
  end

  test "rejects when GPS accuracy exceeds threshold" do
    result = AntiCheatService.new(
      adventure: @adventure, user: @user,
      latitude: @lat, longitude: @long,
      accuracy: 200
    ).call

    assert_not result.ok?
    assert_match(/GPS signal too weak/, result.error)
  end

  test "allows when GPS accuracy is within threshold" do
    result = AntiCheatService.new(
      adventure: @adventure, user: @user,
      latitude: @lat, longitude: @long,
      accuracy: 100
    ).call

    assert result.ok?
  end

  test "allows when accuracy is nil" do
    result = AntiCheatService.new(
      adventure: @adventure, user: @user,
      latitude: @lat, longitude: @long,
      accuracy: nil
    ).call

    assert result.ok?
  end

  test "rate limits when interval is too short" do
    @adventure.update_columns(
      last_check_lat: 38.7749,
      last_check_long: -122.4194,
      last_check_at: 1.second.ago
    )

    result = AntiCheatService.new(
      adventure: @adventure, user: @user,
      latitude: @lat, longitude: @long
    ).call

    assert_not result.ok?
    assert_match(/Too many location checks/, result.error)
  end

  test "rate limit does not update last check position" do
    original_lat = 38.7749
    @adventure.update_columns(
      last_check_lat: original_lat,
      last_check_long: -122.4194,
      last_check_at: 1.second.ago
    )

    AntiCheatService.new(
      adventure: @adventure, user: @user,
      latitude: @lat, longitude: @long
    ).call

    @adventure.reload
    assert_equal original_lat, @adventure.last_check_lat.to_f
  end

  test "allows fast cross-city movement (U-Bahn / tram between clusters)" do
    # Simulate a prior check 60 seconds ago, ~1km away. That's 60 km/h,
    # well above any walking speed — still allowed, transit is normal.
    @adventure.update_columns(
      last_check_lat: 37.7749 + 0.009,  # ~1km north
      last_check_long: -122.4194,
      last_check_at: 60.seconds.ago
    )

    result = AntiCheatService.new(
      adventure: @adventure, user: @user,
      latitude: @lat, longitude: @long
    ).call

    assert result.ok?
  end
end
