require "test_helper"

class DistanceCalculatorTest < ActiveSupport::TestCase
  test "haversine returns zero for identical points" do
    distance = DistanceCalculator.haversine(43.0, 18.0, 43.0, 18.0)
    assert_in_delta 0, distance, 0.01
  end

  test "haversine calculates ~111km for 1 degree latitude" do
    distance = DistanceCalculator.haversine(43.0, 18.0, 44.0, 18.0)
    assert_in_delta 111_000, distance, 1_000
  end

  test "haversine is symmetric" do
    d1 = DistanceCalculator.haversine(43.0, 18.0, 44.0, 19.0)
    d2 = DistanceCalculator.haversine(44.0, 19.0, 43.0, 18.0)
    assert_in_delta d1, d2, 0.01
  end

  test "haversine calculates reasonable transatlantic distance" do
    # New York to London: ~5570 km
    distance = DistanceCalculator.haversine(40.7128, -74.0060, 51.5074, -0.1278)
    assert_in_delta 5_570_000, distance, 50_000
  end

  test "haversine handles equator crossing" do
    distance = DistanceCalculator.haversine(-1.0, 36.0, 1.0, 36.0)
    assert_in_delta 222_000, distance, 2_000
  end

  test "haversine handles antimeridian" do
    distance = DistanceCalculator.haversine(0.0, 179.0, 0.0, -179.0)
    assert_in_delta 222_000, distance, 2_000
  end
end
