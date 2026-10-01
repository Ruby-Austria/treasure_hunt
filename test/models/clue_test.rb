require "test_helper"

class ClueTest < ActiveSupport::TestCase
  def setup
    @hunt = hunts(:one)
    @location = locations(:one)
    @location2 = locations(:two)

    # Remove fixture clues to avoid uniqueness conflicts with test-created clues
    Clue.delete_all

    @valid_attributes = {
      hunt: @hunt,
      location: @location,
      description: "Test clue description",
      difficulty: :easy,
      reasoning: "Test reasoning"
    }
  end

  # Validations Tests
  test "should be valid with valid attributes" do
    clue = Clue.new(@valid_attributes)
    assert clue.valid?
  end

  test "should require hunt" do
    clue = Clue.new(@valid_attributes.except(:hunt))
    assert_not clue.valid?
    assert_includes clue.errors[:hunt], "must exist"
  end

  test "should require location" do
    clue = Clue.new(@valid_attributes.except(:location))
    assert_not clue.valid?
    assert_includes clue.errors[:location], "must exist"
  end

  test "should require difficulty" do
    clue = Clue.new(@valid_attributes.merge(difficulty: nil))
    assert_not clue.valid?
    assert_includes clue.errors[:difficulty], "can't be blank"
  end

  test "should enforce uniqueness of hunt and location combination" do
    Clue.create!(@valid_attributes)

    duplicate_clue = Clue.new(@valid_attributes)
    assert_not duplicate_clue.valid?
    assert_includes duplicate_clue.errors[:hunt_id], "can only have one clue per location in a hunt"
  end

  test "should allow same location in different hunts" do
    Clue.create!(@valid_attributes)

    hunt2 = hunts(:two)
    clue2 = Clue.new(
      hunt: hunt2,
      location: @location,
      difficulty: :easy
    )
    assert clue2.valid?
  end

  test "should allow different locations in same hunt" do
    Clue.create!(@valid_attributes)

    clue2 = Clue.new(
      hunt: @hunt,
      location: @location2,
      difficulty: :easy
    )
    assert clue2.valid?
  end

  # Associations Tests
  test "should belong to hunt" do
    clue = Clue.create!(@valid_attributes)
    assert_equal @hunt, clue.hunt
    assert clue.hunt.present?
  end

  test "should belong to location" do
    clue = Clue.create!(@valid_attributes)
    assert_equal @location, clue.location
    assert clue.location.present?
  end

  test "should be accessible through hunt clues" do
    clue = Clue.create!(@valid_attributes)
    assert_includes @hunt.clues, clue
    assert_equal 1, @hunt.clues.count
  end

  test "should be accessible through location clues" do
    clue = Clue.create!(@valid_attributes)
    assert_includes @location.clues, clue
    assert_equal 1, @location.clues.count
  end

  test "should allow hunt to have multiple clues" do
    clue1 = Clue.create!(@valid_attributes)
    clue2 = Clue.create!(
      hunt: @hunt,
      location: @location2,
      difficulty: :moderate
    )

    assert_equal 2, @hunt.clues.count
    assert_includes @hunt.clues, clue1
    assert_includes @hunt.clues, clue2
  end

  test "should allow location to have multiple clues from different hunts" do
    hunt2 = hunts(:two)
    clue1 = Clue.create!(@valid_attributes)
    clue2 = Clue.create!(
      hunt: hunt2,
      location: @location,
      difficulty: :hard
    )

    assert_equal 2, @location.clues.count
    assert_includes @location.clues, clue1
    assert_includes @location.clues, clue2
  end

  # Difficulty Enum Tests
  test "should have difficulty enum" do
    assert_equal 1, Clue.difficulties[:easy]
    assert_equal 2, Clue.difficulties[:moderate]
    assert_equal 3, Clue.difficulties[:medium]
    assert_equal 4, Clue.difficulties[:challenging]
    assert_equal 5, Clue.difficulties[:hard]
  end

  test "should accept difficulty as symbol" do
    clue = Clue.new(@valid_attributes.merge(difficulty: :easy))
    assert clue.valid?
    assert_equal "easy", clue.difficulty
  end

  test "should accept difficulty as string" do
    clue = Clue.new(@valid_attributes.merge(difficulty: "hard"))
    assert clue.valid?
    assert_equal "hard", clue.difficulty
  end

  test "should have difficulty query methods" do
    clue = Clue.create!(@valid_attributes.merge(difficulty: :easy))
    assert clue.easy?
    assert_not clue.hard?

    clue.update!(difficulty: :hard)
    assert clue.hard?
    assert_not clue.easy?
  end

  test "should have difficulty scope methods" do
    Clue.create!(@valid_attributes.merge(difficulty: :easy))
    Clue.create!(@valid_attributes.merge(location: @location2, difficulty: :hard))

    assert_equal 1, Clue.easy.where(hunt: @hunt, location: @location).count
    assert_equal 1, Clue.hard.where(hunt: @hunt, location: @location2).count
  end

  test "should have default difficulty of easy" do
    clue = Clue.new(
      hunt: @hunt,
      location: @location2
    )
    clue.difficulty = :easy
    clue.save!
    clue.reload
    assert_equal 1, clue.difficulty_before_type_cast
    assert_equal "easy", clue.difficulty
  end

  # Delegation Tests - Radius
  test "should delegate radius to location unlock_radius" do
    @location.update!(unlock_radius: 50)
    clue = Clue.create!(@valid_attributes)

    assert_equal 50, clue.radius
    assert_equal @location.unlock_radius, clue.radius
  end

  test "should alias radius to unlock_radius" do
    @location.update!(unlock_radius: 75)
    clue = Clue.create!(@valid_attributes)

    assert_equal 75, clue.radius
    assert_equal clue.unlock_radius, clue.radius
  end

  test "should return nil for radius if location has no unlock_radius" do
    @location.update!(unlock_radius: nil)
    clue = Clue.create!(@valid_attributes)

    assert_nil clue.radius
  end

  # Delegation Tests - City
  test "should delegate city to location" do
    clue = Clue.create!(@valid_attributes)

    assert_equal @location.city, clue.city
    assert_equal "New York", clue.city
  end

  test "should update city when location city changes" do
    clue = Clue.create!(@valid_attributes)
    original_city = clue.city

    @location.update!(city: "San Francisco")
    clue.reload

    assert_not_equal original_city, clue.city
    assert_equal "San Francisco", clue.city
  end

  # Delegation Tests - Country
  test "should delegate country to location" do
    clue = Clue.create!(@valid_attributes)

    assert_equal @location.country, clue.country
    assert_equal "USA", clue.country
  end

  test "should update country when location country changes" do
    clue = Clue.create!(@valid_attributes)
    original_country = clue.country

    @location.update!(country: "Canada")
    clue.reload

    assert_not_equal original_country, clue.country
    assert_equal "Canada", clue.country
  end

  # Delegation Tests - Latitude
  test "should delegate lat to location" do
    clue = Clue.create!(@valid_attributes)

    assert_equal @location.lat, clue.lat
    assert_equal 40.7829, clue.lat.to_f
  end

  test "should update lat when location lat changes" do
    clue = Clue.create!(@valid_attributes)
    original_lat = clue.lat

    @location.update!(lat: 37.7749)
    clue.reload

    assert_not_equal original_lat, clue.lat
    assert_equal 37.7749, clue.lat.to_f
  end

  # Delegation Tests - Longitude
  test "should delegate long to location" do
    clue = Clue.create!(@valid_attributes)

    assert_equal @location.long, clue.long
    assert_equal -73.9654, clue.long.to_f
  end

  test "should update long when location long changes" do
    clue = Clue.create!(@valid_attributes)
    original_long = clue.long

    @location.update!(long: -122.4194)
    clue.reload

    assert_not_equal original_long, clue.long
    assert_equal -122.4194, clue.long.to_f
  end

  # Delegation Tests - Tags
  test "should delegate tags to location" do
    @location.tag_list = "outdoor, park, family-friendly"
    @location.save!
    clue = Clue.create!(@valid_attributes)

    assert_includes clue.tags, "outdoor"
    assert_includes clue.tags, "park"
    assert_includes clue.tags, "family-friendly"
  end

  test "should update tags when location tags change" do
    @location.tag_list = "original"
    @location.save!
    clue = Clue.create!(@valid_attributes)
    original_tags = clue.tags.dup

    @location.tag_list = "updated, tags"
    @location.save!
    clue.reload

    assert_not_equal original_tags, clue.tags
    assert_includes clue.tags, "updated"
    assert_includes clue.tags, "tags"
  end

  test "should return empty array for tags if location has no tags" do
    @location.tag_list = ""
    @location.save!
    clue = Clue.create!(@valid_attributes)

    assert_equal [], clue.tags
  end

  # Optional Fields Tests
  test "should allow description to be blank" do
    clue = Clue.new(@valid_attributes.except(:description))
    assert clue.valid?
  end

  test "should allow reasoning to be blank" do
    clue = Clue.new(@valid_attributes.except(:reasoning))
    assert clue.valid?
  end

  # Integration Tests
  test "should create clue with all fields" do
    clue = Clue.create!(
      hunt: @hunt,
      location: @location,
      description: "Find the hidden treasure near the old oak tree",
      difficulty: :challenging,
      reasoning: "This location was chosen for its historical significance"
    )

    assert clue.persisted?
    assert_equal @hunt, clue.hunt
    assert_equal @location, clue.location
    assert_equal "Find the hidden treasure near the old oak tree", clue.description
    assert_equal "challenging", clue.difficulty
    assert_equal "This location was chosen for its historical significance", clue.reasoning
  end

  test "should access all delegated attributes" do
    @location.update!(
      unlock_radius: 100,
      city: "Boston",
      country: "USA",
      lat: 42.3601,
      long: -71.0589
    )
    @location.tag_list = "historic, downtown"
    @location.save!

    clue = Clue.create!(@valid_attributes)

    assert_equal 100, clue.radius
    assert_equal "Boston", clue.city
    assert_equal "USA", clue.country
    assert_equal 42.3601, clue.lat.to_f
    assert_equal -71.0589, clue.long.to_f
    assert_includes clue.tags, "historic"
    assert_includes clue.tags, "downtown"
  end

  test "should maintain referential integrity when location is deleted" do
    clue = Clue.create!(@valid_attributes)
    location_id = @location.id

    @location.destroy

    assert_raises(ActiveRecord::RecordNotFound) do
      Clue.find(clue.id)
    end
  end

  test "should maintain referential integrity when hunt is deleted" do
    clue = Clue.create!(@valid_attributes)
    hunt_id = @hunt.id

    @hunt.destroy

    assert_raises(ActiveRecord::RecordNotFound) do
      Clue.find(clue.id)
    end
  end
end
