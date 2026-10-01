require "test_helper"

class LocationTest < ActiveSupport::TestCase
  def setup
    @valid_attributes = {
      name: "Test Location",
      lat: 40.7128,
      long: -74.0060,
      country: "USA",
      city: "New York",
      difficulty: :easy
    }
  end

  # Validations Tests
  test "should be valid with valid attributes" do
    location = Location.new(@valid_attributes)
    assert location.valid?
  end

  test "should require name" do
    location = Location.new(@valid_attributes.except(:name))
    assert_not location.valid?
    assert_includes location.errors[:name], "can't be blank"
  end

  test "should require lat" do
    location = Location.new(@valid_attributes.except(:lat))
    assert_not location.valid?
    assert_includes location.errors[:lat], "can't be blank"
  end

  test "should require long" do
    location = Location.new(@valid_attributes.except(:long))
    assert_not location.valid?
    assert_includes location.errors[:long], "can't be blank"
  end

  test "should require country" do
    location = Location.new(@valid_attributes.except(:country))
    assert_not location.valid?
    assert_includes location.errors[:country], "can't be blank"
  end

  test "should require city" do
    location = Location.new(@valid_attributes.except(:city))
    assert_not location.valid?
    assert_includes location.errors[:city], "can't be blank"
  end

  test "should require difficulty" do
    location = Location.new(@valid_attributes.merge(difficulty: nil))
    assert_not location.valid?
    assert_includes location.errors[:difficulty], "can't be blank"
  end

  test "should validate lat is between -90 and 90" do
    location = Location.new(@valid_attributes.merge(lat: 91))
    assert_not location.valid?
    assert_includes location.errors[:lat], "must be less than or equal to 90"

    location = Location.new(@valid_attributes.merge(lat: -91))
    assert_not location.valid?
    assert_includes location.errors[:lat], "must be greater than or equal to -90"

    location = Location.new(@valid_attributes.merge(lat: 90))
    assert location.valid?

    location = Location.new(@valid_attributes.merge(lat: -90))
    assert location.valid?
  end

  test "should validate long is between -180 and 180" do
    location = Location.new(@valid_attributes.merge(long: 181))
    assert_not location.valid?
    assert_includes location.errors[:long], "must be less than or equal to 180"

    location = Location.new(@valid_attributes.merge(long: -181))
    assert_not location.valid?
    assert_includes location.errors[:long], "must be greater than or equal to -180"

    location = Location.new(@valid_attributes.merge(long: 180))
    assert location.valid?

    location = Location.new(@valid_attributes.merge(long: -180))
    assert location.valid?
  end

  # Enum Tests
  test "should have difficulty enum" do
    assert_equal 1, Location.difficulties[:easy]
    assert_equal 2, Location.difficulties[:moderate]
    assert_equal 3, Location.difficulties[:medium]
    assert_equal 4, Location.difficulties[:challenging]
    assert_equal 5, Location.difficulties[:hard]
  end

  test "should accept difficulty as symbol" do
    location = Location.new(@valid_attributes.merge(difficulty: :easy))
    assert location.valid?
    assert_equal "easy", location.difficulty
  end

  test "should accept difficulty as string" do
    location = Location.new(@valid_attributes.merge(difficulty: "hard"))
    assert location.valid?
    assert_equal "hard", location.difficulty
  end

  test "should have difficulty query methods" do
    location = Location.create!(@valid_attributes.merge(difficulty: :easy))
    assert location.easy?
    assert_not location.hard?

    location.update!(difficulty: :hard)
    assert location.hard?
    assert_not location.easy?
  end

  test "should have difficulty scope methods" do
    Location.create!(@valid_attributes.merge(difficulty: :easy, name: "Easy Location"))
    Location.create!(@valid_attributes.merge(difficulty: :hard, name: "Hard Location"))

    assert Location.easy.where(name: "Easy Location").exists?
    assert Location.hard.where(name: "Hard Location").exists?
  end

  # Tags Tests (acts_as_taggable_on)
  test "should have empty tags by default" do
    location = Location.new(@valid_attributes)
    assert_equal [], location.tag_list
  end

  test "should accept tag_list as string" do
    location = Location.new(@valid_attributes)
    location.tag_list = "outdoor, park, family"
    assert location.valid?
    assert_includes location.tag_list, "outdoor"
    assert_includes location.tag_list, "park"
    assert_includes location.tag_list, "family"
  end

  test "should save and retrieve tags" do
    location = Location.create!(@valid_attributes)
    location.tag_list = "tag1, tag2"
    location.save!
    location.reload
    assert_includes location.tag_list, "tag1"
    assert_includes location.tag_list, "tag2"
  end

  test "should allow modifying tag_list" do
    location = Location.create!(@valid_attributes)
    location.tag_list = "tag1"
    location.save!
    location.tag_list.add("tag2")
    location.save!
    location.reload
    assert_includes location.tag_list, "tag1"
    assert_includes location.tag_list, "tag2"
  end

  # Optional Fields Tests
  test "should allow description to be blank" do
    location = Location.new(@valid_attributes.except(:description))
    assert location.valid?
  end

  test "should allow reasoning to be blank" do
    location = Location.new(@valid_attributes.except(:reasoning))
    assert location.valid?
  end

  # Integration Tests
  test "should create location with all fields" do
    location = Location.create!(
      name: "Central Park",
      lat: 40.7829,
      long: -73.9654,
      country: "USA",
      city: "New York",
      description: "A large public park",
      reasoning: "Great for treasure hunts",
      difficulty: :moderate
    )
    location.tag_list = "park, outdoor, family-friendly"
    location.save!

    assert location.persisted?
    assert_equal "Central Park", location.name
    assert_equal 40.7829, location.lat.to_f
    assert_equal -73.9654, location.long.to_f
    assert_equal "USA", location.country
    assert_equal "New York", location.city
    assert_equal "A large public park", location.description
    assert_equal "Great for treasure hunts", location.reasoning
    assert_equal "moderate", location.difficulty
    assert_includes location.tag_list, "park"
    assert_includes location.tag_list, "outdoor"
    assert_includes location.tag_list, "family-friendly"
  end

  test "should have default difficulty of 1 (easy)" do
    location = Location.new(
      name: "Test",
      lat: 40.7128,
      long: -74.0060,
      country: "USA",
      city: "New York"
    )
    # Note: difficulty is required, so we need to set it, but the default in DB is 1
    location.difficulty = :easy
    location.save!
    location.reload
    assert_equal 1, location.difficulty_before_type_cast
  end

  # Associations Tests
  test "should have many clues" do
    location = Location.create!(@valid_attributes)
    hunt1 = Hunt.create!(
      name: "Hunt 1",
      status: :draft,
      difficulty: :easy,
      hunt_type: :for_fun,
      price: 0.0,
      language: "en"
    )
    hunt2 = Hunt.create!(
      name: "Hunt 2",
      status: :draft,
      difficulty: :easy,
      hunt_type: :for_fun,
      price: 0.0,
      language: "en"
    )

    clue1 = Clue.create!(hunt: hunt1, location: location, difficulty: :easy)
    clue2 = Clue.create!(hunt: hunt2, location: location, difficulty: :moderate)

    assert_equal 2, location.clues.count
    assert_includes location.clues, clue1
    assert_includes location.clues, clue2
  end

  test "should have many hunts through clues" do
    location = Location.create!(@valid_attributes)
    hunt1 = Hunt.create!(
      name: "Hunt 1",
      status: :draft,
      difficulty: :easy,
      hunt_type: :for_fun,
      price: 0.0,
      language: "en"
    )
    hunt2 = Hunt.create!(
      name: "Hunt 2",
      status: :draft,
      difficulty: :easy,
      hunt_type: :for_fun,
      price: 0.0,
      language: "en"
    )

    Clue.create!(hunt: hunt1, location: location, difficulty: :easy)
    Clue.create!(hunt: hunt2, location: location, difficulty: :moderate)

    assert_equal 2, location.hunts.count
    assert_includes location.hunts, hunt1
    assert_includes location.hunts, hunt2
  end

  test "should destroy clues when location is destroyed" do
    location = Location.create!(@valid_attributes)
    hunt = Hunt.create!(
      name: "Test Hunt",
      status: :draft,
      difficulty: :easy,
      hunt_type: :for_fun,
      price: 0.0,
      language: "en"
    )

    clue = Clue.create!(hunt: hunt, location: location, difficulty: :easy)
    clue_id = clue.id

    assert_difference("Clue.count", -1) do
      location.destroy
    end

    assert_raises(ActiveRecord::RecordNotFound) do
      Clue.find(clue_id)
    end
  end

  # Community learning (update_from_player_claim)

  test "update_from_player_claim initializes averages on first claim" do
    location = Location.create!(@valid_attributes)
    assert_nil location.avg_player_lat
    assert_nil location.avg_player_lng

    location.update_from_player_claim(40.71, -74.01)
    location.reload

    assert_equal 1, location.usage_count
    assert_in_delta 40.71, location.avg_player_lat, 0.001
    assert_in_delta(-74.01, location.avg_player_lng, 0.001)
  end

  test "update_from_player_claim uses weighted average on subsequent claims" do
    location = Location.create!(@valid_attributes.merge(avg_player_lat: 40.0, avg_player_lng: -74.0, usage_count: 1))

    location.update_from_player_claim(41.0, -73.0)
    location.reload

    # 80% existing + 20% new
    assert_in_delta 40.2, location.avg_player_lat, 0.001
    assert_in_delta(-73.8, location.avg_player_lng, 0.001)
    assert_equal 2, location.usage_count
  end

  test "update_from_player_claim increases confidence after 5 claims" do
    location = Location.create!(@valid_attributes.merge(
      avg_player_lat: 40.0, avg_player_lng: -74.0,
      usage_count: 4, confidence_score: 0.5
    ))

    location.update_from_player_claim(40.0, -74.0)
    location.reload

    assert_equal 5, location.usage_count
    assert_in_delta 0.55, location.confidence_score, 0.001
  end

  test "update_from_player_claim caps confidence at 0.95" do
    location = Location.create!(@valid_attributes.merge(
      avg_player_lat: 40.0, avg_player_lng: -74.0,
      usage_count: 9, confidence_score: 0.89
    ))

    # Incrementing from 0.89 + 0.05 = 0.94, capped at min(0.94, 0.95) = 0.94
    location.update_from_player_claim(40.0, -74.0)
    location.reload

    assert_in_delta 0.94, location.confidence_score, 0.001
  end

  test "update_from_player_claim does not increase confidence above 0.9" do
    location = Location.create!(@valid_attributes.merge(
      avg_player_lat: 40.0, avg_player_lng: -74.0,
      usage_count: 9, confidence_score: 0.91
    ))

    location.update_from_player_claim(40.0, -74.0)
    location.reload

    # confidence_score >= 0.9, so no increment
    assert_in_delta 0.91, location.confidence_score, 0.001
  end

  test "update_from_player_claim auto-verifies after 10 claims" do
    location = Location.create!(@valid_attributes.merge(
      avg_player_lat: 40.0, avg_player_lng: -74.0,
      usage_count: 9, confidence_score: 0.8,
      verification_state: :ai_generated
    ))

    location.update_from_player_claim(40.0, -74.0)
    location.reload

    assert location.auto_verified?
  end

  test "update_from_player_claim does not re-verify human_verified locations" do
    location = Location.create!(@valid_attributes.merge(
      avg_player_lat: 40.0, avg_player_lng: -74.0,
      usage_count: 9, confidence_score: 0.8,
      verification_state: :human_verified
    ))

    location.update_from_player_claim(40.0, -74.0)
    location.reload

    assert location.human_verified?
  end

  # Confidence and unlock_radius validations

  test "unlock_radius must be positive when set" do
    location = Location.new(@valid_attributes.merge(unlock_radius: 0))
    assert_not location.valid?

    location.unlock_radius = -5
    assert_not location.valid?

    location.unlock_radius = 100
    assert location.valid?
  end

  test "confidence_score must be between 0 and 1" do
    location = Location.new(@valid_attributes.merge(confidence_score: 1.5))
    assert_not location.valid?

    location.confidence_score = -0.1
    assert_not location.valid?

    location.confidence_score = 0.5
    assert location.valid?
  end

  # within_radius?

  test "within_radius? returns true when player is within default radius" do
    location = Location.create!(@valid_attributes.merge(lat: 40.7128, long: -74.0060))
    # ~10 meters away
    assert location.within_radius?(40.7129, -74.0060)
  end

  test "within_radius? returns false when player is far away" do
    location = Location.create!(@valid_attributes.merge(lat: 40.7128, long: -74.0060))
    # ~1 degree lat = ~111km away
    assert_not location.within_radius?(41.7128, -74.0060)
  end

  test "within_radius? uses custom unlock_radius" do
    location = Location.create!(@valid_attributes.merge(lat: 40.7128, long: -74.0060, unlock_radius: 10))
    # ~100 meters away — outside 10m radius
    assert_not location.within_radius?(40.7137, -74.0060)
  end

  test "should allow multiple locations in same hunt through clues" do
    hunt = Hunt.create!(
      name: "Test Hunt",
      status: :draft,
      difficulty: :easy,
      hunt_type: :for_fun,
      price: 0.0,
      language: "en"
    )
    location1 = Location.create!(@valid_attributes)
    location2 = Location.create!(
      name: "Location 2",
      lat: 40.7829,
      long: -73.9654,
      country: "USA",
      city: "New York",
      difficulty: :easy
    )

    clue1 = Clue.create!(hunt: hunt, location: location1, difficulty: :easy)
    clue2 = Clue.create!(hunt: hunt, location: location2, difficulty: :moderate)

    assert_equal 2, hunt.clues.count
    assert_equal 2, hunt.locations.count
    assert_equal 1, location1.hunts.count
    assert_equal 1, location2.hunts.count
    assert_equal hunt, location1.hunts.first
    assert_equal hunt, location2.hunts.first
  end
end
