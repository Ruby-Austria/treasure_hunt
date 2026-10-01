require "test_helper"

class LocationCheckServiceTest < ActiveSupport::TestCase
  def setup
    # Create a test location (using coordinates that are easy to work with)
    # Using coordinates near San Francisco for testing
    @location = Location.new(
      name: "Test Location",
      city: "San Francisco",
      country: "USA",
      lat: 37.7749,
      long: -122.4194
    )
  end

  test "should return can_claim true when user is within unlock radius" do
    # User at the same location (distance = 0)
    service = LocationCheckService.new(
      user_lat: 37.7749,
      user_long: -122.4194,
      clue_location: @location,
      unlock_radius: 50
    )

    result = service.call

    assert result[:can_claim]
    assert_equal 0.0, result[:distance]
    assert_equal 50, result[:unlock_radius]
  end

  test "should return can_claim false when user is outside unlock radius" do
    # User 100 meters away (beyond 50m radius)
    # Approximately 0.0009 degrees latitude = ~100 meters
    service = LocationCheckService.new(
      user_lat: 37.7758, # ~100m north
      user_long: -122.4194,
      clue_location: @location,
      unlock_radius: 50
    )

    result = service.call

    assert_not result[:can_claim]
    assert result[:distance] > 50
    assert_equal 50, result[:unlock_radius]
  end

  test "should use default unlock radius of 50 meters when not provided" do
    service = LocationCheckService.new(
      user_lat: 37.7749,
      user_long: -122.4194,
      clue_location: @location
    )

    result = service.call

    assert_equal 50, result[:unlock_radius]
  end

  test "should calculate distance correctly using Haversine formula" do
    # Test with known coordinates
    # Distance between two points approximately 1km apart
    location1 = Location.new(lat: 37.7749, long: -122.4194, name: "Loc1", city: "SF", country: "USA")
    location2 = Location.new(lat: 37.7849, long: -122.4194, name: "Loc2", city: "SF", country: "USA")

    service = LocationCheckService.new(
      user_lat: location1.lat,
      user_long: location1.long,
      clue_location: location2,
      unlock_radius: 2000
    )

    result = service.call

    # Should be approximately 1111 meters (0.01 degrees latitude ≈ 1111m)
    assert result[:distance] > 1000
    assert result[:distance] < 1200
  end

  test "should return hot temperature message when very close" do
    service = LocationCheckService.new(
      user_lat: 37.7749,
      user_long: -122.4194,
      clue_location: @location,
      unlock_radius: 50
    )

    result = service.call

    assert_equal "hot", result[:temperature][:level]
    assert_match /very close/i, result[:temperature][:message]
  end

  test "should return warm temperature message when moderately close" do
    # User approximately 75 meters away
    service = LocationCheckService.new(
      user_lat: 37.7756, # ~75m away
      user_long: -122.4194,
      clue_location: @location,
      unlock_radius: 200
    )

    result = service.call

    assert_equal "warm", result[:temperature][:level]
    assert_match /warm/i, result[:temperature][:message]
  end

  test "should return closer temperature message when getting closer" do
    # User approximately 150 meters away
    service = LocationCheckService.new(
      user_lat: 37.7763, # ~150m away
      user_long: -122.4194,
      clue_location: @location,
      unlock_radius: 200
    )

    result = service.call

    assert_equal "closer", result[:temperature][:level]
    assert_match /Getting closer/i, result[:temperature][:message]
  end

  test "should return cold temperature message when far away" do
    # User approximately 500 meters away
    service = LocationCheckService.new(
      user_lat: 37.7795, # ~500m away
      user_long: -122.4194,
      clue_location: @location,
      unlock_radius: 200
    )

    result = service.call

    assert_equal "cold", result[:temperature][:level]
    assert_match /Keep searching/i, result[:temperature][:message]
  end

  test "should return user and clue locations in result" do
    user_lat = 37.7749
    user_long = -122.4194

    service = LocationCheckService.new(
      user_lat: user_lat,
      user_long: user_long,
      clue_location: @location,
      unlock_radius: 50
    )

    result = service.call

    assert_equal user_lat, result[:user_location][:lat]
    assert_equal user_long, result[:user_location][:long]
    assert_equal @location.lat, result[:clue_location][:lat]
    assert_equal @location.long, result[:clue_location][:long]
  end

  test "should handle custom unlock radius" do
    service = LocationCheckService.new(
      user_lat: 37.7749,
      user_long: -122.4194,
      clue_location: @location,
      unlock_radius: 100
    )

    result = service.call

    assert_equal 100, result[:unlock_radius]
  end

  test "should round distance to 2 decimal places" do
    service = LocationCheckService.new(
      user_lat: 37.7750,
      user_long: -122.4194,
      clue_location: @location,
      unlock_radius: 50
    )

    result = service.call

    # Distance should be rounded to 2 decimal places
    distance_string = result[:distance].to_s
    decimal_places = distance_string.split(".").last.length if distance_string.include?(".")
    assert decimal_places.nil? || decimal_places <= 2, "Distance should be rounded to 2 decimal places"
  end

  test "should handle edge case when user is exactly at unlock radius boundary" do
    # This test verifies the boundary condition: distance == unlock_radius
    # Since we use <= for comparison, user should be able to claim
    service = LocationCheckService.new(
      user_lat: 37.7749,
      user_long: -122.4194,
      clue_location: @location,
      unlock_radius: 0
    )

    result = service.call

    # When distance is 0 and unlock_radius is 0, can_claim should be true
    assert result[:can_claim]
    assert_equal 0.0, result[:distance]
  end
end
