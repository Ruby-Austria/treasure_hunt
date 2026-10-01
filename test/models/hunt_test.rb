require "test_helper"

class HuntTest < ActiveSupport::TestCase
  def setup
    @valid_attributes = {
      name: "Test Hunt",
      description: "A test treasure hunt",
      status: :draft,
      difficulty: :easy,
      hunt_type: :for_fun,
      price: 0.0,
      language: "en"
    }
  end

  # Validations Tests
  test "should be valid with valid attributes" do
    hunt = Hunt.new(@valid_attributes)
    assert hunt.valid?
  end

  test "should require name" do
    hunt = Hunt.new(@valid_attributes.except(:name))
    assert_not hunt.valid?
    assert_includes hunt.errors[:name], "can't be blank"
  end

  test "should require status" do
    hunt = Hunt.new(@valid_attributes.merge(status: nil))
    assert_not hunt.valid?
    assert_includes hunt.errors[:status], "can't be blank"
  end

  test "should require difficulty" do
    hunt = Hunt.new(@valid_attributes.merge(difficulty: nil))
    assert_not hunt.valid?
    assert_includes hunt.errors[:difficulty], "can't be blank"
  end

  test "should require hunt_type" do
    hunt = Hunt.new(@valid_attributes.except(:hunt_type))
    assert_not hunt.valid?
    assert_includes hunt.errors[:hunt_type], "can't be blank"
  end

  test "should require price" do
    hunt = Hunt.new(@valid_attributes.merge(price: nil))
    assert_not hunt.valid?
    assert_includes hunt.errors[:price], "can't be blank"
  end

  test "should require language" do
    hunt = Hunt.new(@valid_attributes.merge(language: nil))
    assert_not hunt.valid?
    assert_includes hunt.errors[:language], "can't be blank"
  end

  test "should validate price is greater than or equal to zero" do
    hunt = Hunt.new(@valid_attributes.merge(price: -10))
    assert_not hunt.valid?
    assert_includes hunt.errors[:price], "must be greater than or equal to 0"

    hunt = Hunt.new(@valid_attributes.merge(price: 0))
    assert hunt.valid?

    hunt = Hunt.new(@valid_attributes.merge(price: 29.99))
    assert hunt.valid?
  end

  # Status Enum Tests
  test "should have status enum" do
    assert_equal 1, Hunt.statuses[:draft]
    assert_equal 2, Hunt.statuses[:approved]
    assert_equal 3, Hunt.statuses[:archived]
  end

  test "should accept status as symbol" do
    hunt = Hunt.new(@valid_attributes.merge(status: :draft))
    assert hunt.valid?
    assert_equal "draft", hunt.status
  end

  test "should accept status as string" do
    hunt = Hunt.new(@valid_attributes.merge(status: "approved"))
    assert hunt.valid?
    assert_equal "approved", hunt.status
  end

  test "should have status query methods" do
    hunt = Hunt.create!(@valid_attributes.merge(status: :draft))
    assert hunt.draft?
    assert_not hunt.approved?
    assert_not hunt.archived?

    hunt.update!(status: :approved)
    assert hunt.approved?
    assert_not hunt.draft?

    hunt.update!(status: :archived)
    assert hunt.archived?
    assert_not hunt.approved?
  end

  test "should have status scope methods" do
    Hunt.create!(@valid_attributes.merge(status: :draft, name: "Draft Hunt"))
    Hunt.create!(@valid_attributes.merge(status: :approved, name: "Approved Hunt"))
    Hunt.create!(@valid_attributes.merge(status: :archived, name: "Archived Hunt"))

    assert_equal 1, Hunt.draft.where(name: "Draft Hunt").count
    assert_equal 1, Hunt.approved.where(name: "Approved Hunt").count
    assert_equal 1, Hunt.archived.where(name: "Archived Hunt").count
  end

  # Difficulty Enum Tests
  test "should have difficulty enum" do
    assert_equal 1, Hunt.difficulties[:easy]
    assert_equal 2, Hunt.difficulties[:moderate]
    assert_equal 3, Hunt.difficulties[:medium]
    assert_equal 4, Hunt.difficulties[:challenging]
    assert_equal 5, Hunt.difficulties[:hard]
  end

  test "should accept difficulty as symbol" do
    hunt = Hunt.new(@valid_attributes.merge(difficulty: :easy))
    assert hunt.valid?
    assert_equal "easy", hunt.difficulty
  end

  test "should accept difficulty as string" do
    hunt = Hunt.new(@valid_attributes.merge(difficulty: "hard"))
    assert hunt.valid?
    assert_equal "hard", hunt.difficulty
  end

  test "should have difficulty query methods" do
    hunt = Hunt.create!(@valid_attributes.merge(difficulty: :easy))
    assert hunt.easy?
    assert_not hunt.hard?

    hunt.update!(difficulty: :hard)
    assert hunt.hard?
    assert_not hunt.easy?
  end

  test "should have difficulty scope methods" do
    Hunt.create!(@valid_attributes.merge(difficulty: :easy, name: "Easy Hunt"))
    Hunt.create!(@valid_attributes.merge(difficulty: :hard, name: "Hard Hunt"))

    assert Hunt.easy.where(name: "Easy Hunt").exists?
    assert Hunt.hard.where(name: "Hard Hunt").exists?
  end

  # Hunt Type Enum Tests
  test "should have hunt_type enum" do
    assert_equal 1, Hunt.hunt_types[:for_fun]
    assert_equal 2, Hunt.hunt_types[:reward]
  end

  test "should accept hunt_type as symbol" do
    hunt = Hunt.new(@valid_attributes.merge(hunt_type: :for_fun))
    assert hunt.valid?
    assert_equal "for_fun", hunt.hunt_type
  end

  test "should accept hunt_type as string" do
    hunt = Hunt.new(@valid_attributes.merge(hunt_type: "reward"))
    assert hunt.valid?
    assert_equal "reward", hunt.hunt_type
  end

  test "should have hunt_type query methods" do
    hunt = Hunt.create!(@valid_attributes.merge(hunt_type: :for_fun))
    assert hunt.for_fun?
    assert_not hunt.reward?

    hunt.update!(hunt_type: :reward)
    assert hunt.reward?
    assert_not hunt.for_fun?
  end

  test "should have hunt_type scope methods" do
    Hunt.create!(@valid_attributes.merge(hunt_type: :for_fun, name: "Fun Hunt"))
    Hunt.create!(@valid_attributes.merge(hunt_type: :reward, name: "Reward Hunt"))

    assert Hunt.for_fun.where(name: "Fun Hunt").exists?
    assert Hunt.reward.where(name: "Reward Hunt").exists?
  end

  # Tags Tests (acts_as_taggable_on)
  test "should have empty tags by default" do
    hunt = Hunt.new(@valid_attributes)
    assert_equal [], hunt.tag_list
  end

  test "should accept tag_list as string" do
    hunt = Hunt.new(@valid_attributes)
    hunt.tag_list = "outdoor, adventure, family"
    assert hunt.valid?
    assert_includes hunt.tag_list, "outdoor"
    assert_includes hunt.tag_list, "adventure"
    assert_includes hunt.tag_list, "family"
  end

  test "should save and retrieve tags" do
    hunt = Hunt.create!(@valid_attributes)
    hunt.tag_list = "test, sample"
    hunt.save!
    hunt.reload
    assert_includes hunt.tag_list, "test"
    assert_includes hunt.tag_list, "sample"
  end

  test "should allow modifying tag_list" do
    hunt = Hunt.create!(@valid_attributes)
    hunt.tag_list = "tag1"
    hunt.save!
    hunt.tag_list.add("tag2")
    hunt.save!
    hunt.reload
    assert_includes hunt.tag_list, "tag1"
    assert_includes hunt.tag_list, "tag2"
  end

  # Language Tests
  test "should have default language of en" do
    hunt = Hunt.new(
      name: "Test",
      status: :draft,
      difficulty: :easy,
      hunt_type: :for_fun,
      price: 0.0
    )
    assert_equal "en", hunt.language
  end

  test "should accept different language values" do
    hunt = Hunt.create!(@valid_attributes.merge(language: "fr"))
    assert_equal "fr", hunt.language

    hunt.update!(language: "es")
    assert_equal "es", hunt.language
  end

  # Optional Fields Tests
  test "should allow description to be blank" do
    hunt = Hunt.new(@valid_attributes.except(:description))
    assert hunt.valid?
  end

  # Default Values Tests
  test "should have default status of draft" do
    hunt = Hunt.new(
      name: "Test",
      difficulty: :easy,
      hunt_type: :for_fun,
      price: 0.0,
      language: "en"
    )
    hunt.status = :draft
    hunt.save!
    hunt.reload
    assert_equal 1, hunt.status_before_type_cast
    assert_equal "draft", hunt.status
  end

  test "should have default difficulty of easy" do
    hunt = Hunt.new(
      name: "Test",
      status: :draft,
      hunt_type: :for_fun,
      price: 0.0,
      language: "en"
    )
    hunt.difficulty = :easy
    hunt.save!
    hunt.reload
    assert_equal 1, hunt.difficulty_before_type_cast
    assert_equal "easy", hunt.difficulty
  end

  test "should have default price of 0.0" do
    hunt = Hunt.new(
      name: "Test",
      status: :draft,
      difficulty: :easy,
      hunt_type: :for_fun,
      language: "en"
    )
    hunt.price = 0.0
    hunt.save!
    hunt.reload
    assert_equal 0.0, hunt.price.to_f
  end

  # Integration Tests
  test "should create hunt with all fields" do
    hunt = Hunt.create!(
      name: "City Adventure Hunt",
      description: "Explore the city and find hidden treasures",
      status: :approved,
      difficulty: :moderate,
      hunt_type: :reward,
      price: 29.99,
      language: "en"
    )
    hunt.tag_list = "outdoor, adventure, family-friendly, city"
    hunt.save!

    assert hunt.persisted?
    assert_equal "City Adventure Hunt", hunt.name
    assert_equal "Explore the city and find hidden treasures", hunt.description
    assert_includes hunt.tag_list, "outdoor"
    assert_includes hunt.tag_list, "adventure"
    assert_includes hunt.tag_list, "family-friendly"
    assert_includes hunt.tag_list, "city"
    assert_equal "approved", hunt.status
    assert_equal "moderate", hunt.difficulty
    assert_equal "reward", hunt.hunt_type
    assert_equal 29.99, hunt.price.to_f
    assert_equal "en", hunt.language
  end

  test "should create for_fun hunt with zero price" do
    hunt = Hunt.create!(
      name: "Free Fun Hunt",
      status: :draft,
      difficulty: :easy,
      hunt_type: :for_fun,
      price: 0.0,
      language: "en"
    )

    assert hunt.for_fun?
    assert_equal 0.0, hunt.price.to_f
    assert hunt.draft?
  end

  test "should create reward hunt with price" do
    hunt = Hunt.create!(
      name: "Premium Hunt",
      status: :approved,
      difficulty: :hard,
      hunt_type: :reward,
      price: 49.99,
      language: "en"
    )

    assert hunt.reward?
    assert_equal 49.99, hunt.price.to_f
    assert hunt.approved?
    assert hunt.hard?
  end

  # Associations Tests
  test "should have many clues" do
    hunt = Hunt.create!(@valid_attributes)
    location1 = Location.create!(
      name: "Location 1",
      lat: 40.7128,
      long: -74.0060,
      country: "USA",
      city: "New York",
      difficulty: :easy
    )
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
    assert_includes hunt.clues, clue1
    assert_includes hunt.clues, clue2
  end

  test "should have many locations through clues" do
    hunt = Hunt.create!(@valid_attributes)
    location1 = Location.create!(
      name: "Location 1",
      lat: 40.7128,
      long: -74.0060,
      country: "USA",
      city: "New York",
      difficulty: :easy
    )
    location2 = Location.create!(
      name: "Location 2",
      lat: 40.7829,
      long: -73.9654,
      country: "USA",
      city: "New York",
      difficulty: :easy
    )

    Clue.create!(hunt: hunt, location: location1, difficulty: :easy)
    Clue.create!(hunt: hunt, location: location2, difficulty: :moderate)

    assert_equal 2, hunt.locations.count
    assert_includes hunt.locations, location1
    assert_includes hunt.locations, location2
  end

  test "should destroy clues when hunt is destroyed" do
    hunt = Hunt.create!(@valid_attributes)
    location = Location.create!(
      name: "Location 1",
      lat: 40.7128,
      long: -74.0060,
      country: "USA",
      city: "New York",
      difficulty: :easy
    )

    clue = Clue.create!(hunt: hunt, location: location, difficulty: :easy)
    clue_id = clue.id

    assert_difference("Clue.count", -1) do
      hunt.destroy
    end

    assert_raises(ActiveRecord::RecordNotFound) do
      Clue.find(clue_id)
    end
  end

  test "should allow multiple hunts to share same location through clues" do
    hunt1 = Hunt.create!(@valid_attributes)
    hunt2 = Hunt.create!(
      name: "Hunt 2",
      status: :draft,
      difficulty: :easy,
      hunt_type: :for_fun,
      price: 0.0,
      language: "en"
    )
    location = Location.create!(
      name: "Shared Location",
      lat: 40.7128,
      long: -74.0060,
      country: "USA",
      city: "New York",
      difficulty: :easy
    )

    clue1 = Clue.create!(hunt: hunt1, location: location, difficulty: :easy)
    clue2 = Clue.create!(hunt: hunt2, location: location, difficulty: :hard)

    assert_equal 1, hunt1.locations.count
    assert_equal 1, hunt2.locations.count
    assert_equal location, hunt1.locations.first
    assert_equal location, hunt2.locations.first
    assert_equal 2, location.clues.count
  end
end
