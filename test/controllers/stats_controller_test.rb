# frozen_string_literal: true

require "test_helper"

class StatsControllerTest < ActionDispatch::IntegrationTest
  test "should get stats without authentication" do
    get stats_url(format: :json)
    assert_response :success
  end

  test "should return json with platform statistics" do
    get stats_url(format: :json)

    json_response = JSON.parse(response.body)

    assert json_response.key?("hunts")
    assert json_response.key?("clues")
    assert json_response.key?("locations")
    assert json_response.key?("cities")
    assert json_response.key?("countries")
    assert json_response.key?("generated_at")
  end

  test "should return correct hunt count" do
    # Use an existing fixture hunt
    hunt = hunts(:two)
    hunt.update!(status: :approved)

    # Clear cache
    Rails.cache.delete("platform_stats")

    get stats_url(format: :json)
    json_response = JSON.parse(response.body)

    assert_operator json_response["hunts"], :>=, 1
  end

  test "should cache stats for 5 minutes" do
    # Use memory store to test caching (test env uses null_store by default)
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    Rails.cache.delete("platform_stats")

    # First request
    get stats_url(format: :json)
    first_response = JSON.parse(response.body)

    # Create new hunt (should not appear due to cache)
    Hunt.create!(
      name: "Test Hunt",
      description: "Test",
      status: :approved,
      difficulty: :easy,
      hunt_type: :for_fun,
      price: 0.0,
      language: "en"
    )

    # Second request (should return cached value)
    get stats_url(format: :json)
    second_response = JSON.parse(response.body)

    # Should have same hunt count (cache active)
    assert_equal first_response["hunts"], second_response["hunts"]
  ensure
    Rails.cache = original_cache
  end

  test "should return zero for counts when no data exists" do
    # Clear all data
    Clue.delete_all
    Adventure.delete_all
    Hunt.delete_all
    Location.delete_all

    # Clear cache
    Rails.cache.delete("platform_stats")

    get stats_url(format: :json)
    json_response = JSON.parse(response.body)

    assert_equal 0, json_response["hunts"]
    assert_equal 0, json_response["locations"]
    assert_equal 0, json_response["cities"]
  end
end
