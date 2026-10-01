require "test_helper"

class AdventureTest < ActiveSupport::TestCase
  def setup
    @user = users(:regular_user)
    @hunt = hunts(:two) # approved hunt
    @hunt.update!(status: :approved)

    # Ensure hunt has clues
    @location = locations(:one)
    @clue1 = Clue.find_or_create_by!(hunt: @hunt, location: @location) { |c| c.difficulty = :easy }
    @location2 = locations(:two)
    @clue2 = Clue.find_or_create_by!(hunt: @hunt, location: @location2) { |c| c.difficulty = :moderate }

    # Clear any existing in_progress adventures for this user/hunt to avoid unique constraint
    @user.adventures.where(hunt: @hunt, status: :in_progress).destroy_all

    @valid_attributes = {
      user: @user,
      hunt: @hunt,
      status: :in_progress
    }
  end

  # Validations Tests
  test "should be valid with valid attributes" do
    adventure = Adventure.new(@valid_attributes)
    assert adventure.valid?
  end

  test "should require user" do
    adventure = Adventure.new(@valid_attributes.except(:user))
    assert_not adventure.valid?
    assert_includes adventure.errors[:user], "must exist"
  end

  test "should require hunt" do
    adventure = Adventure.new(@valid_attributes.except(:hunt))
    assert_not adventure.valid?
    assert_includes adventure.errors[:hunt], "must exist"
  end

  test "should require status" do
    adventure = Adventure.new(@valid_attributes.merge(status: nil))
    assert_not adventure.valid?
    assert_includes adventure.errors[:status], "can't be blank"
  end

  test "should not allow multiple in_progress adventures per user per hunt" do
    Adventure.create!(@valid_attributes)

    adventure2 = Adventure.new(@valid_attributes)
    assert_not adventure2.valid?
    assert adventure2.errors[:base].any?
  end

  # Associations Tests
  test "should belong to user" do
    adventure = Adventure.create!(@valid_attributes)
    assert_equal @user, adventure.user
    assert adventure.user.present?
  end

  test "should belong to hunt" do
    adventure = Adventure.create!(@valid_attributes)
    assert_equal @hunt, adventure.hunt
    assert adventure.hunt.present?
  end

  test "should be accessible through user adventures" do
    adventure = Adventure.create!(@valid_attributes)
    assert_includes @user.adventures, adventure
  end

  test "should be accessible through hunt adventures" do
    adventure = Adventure.create!(@valid_attributes)
    assert_includes @hunt.adventures, adventure
  end

  # Status Enum Tests
  test "should have status enum" do
    assert_equal 1, Adventure.statuses[:in_progress]
    assert_equal 2, Adventure.statuses[:completed]
  end

  test "should accept in_progress status" do
    adventure = Adventure.new(@valid_attributes.merge(status: :in_progress))
    assert adventure.valid?
    assert adventure.in_progress?
  end

  test "should accept completed status" do
    adventure = Adventure.new(@valid_attributes.merge(status: :completed))
    assert adventure.valid?
    assert adventure.completed?
  end

  # Current Clue Tests
  test "should set current_clue on create when hunt has clues" do
    adventure = Adventure.create!(@valid_attributes)
    adventure.reload

    assert_not_nil adventure.current_clue_id
    assert_includes @hunt.clues.pluck(:id), adventure.current_clue_id
  end

  # Ensure Current Clue Tests
  test "ensure_current_clue! returns true when current_clue is already set" do
    adventure = Adventure.create!(@valid_attributes)
    assert_not_nil adventure.current_clue_id
    assert adventure.ensure_current_clue!
  end

  test "ensure_current_clue! assigns clue when current_clue is nil" do
    adventure = Adventure.create!(@valid_attributes)
    adventure.update_column(:current_clue_id, nil)
    adventure.reload

    assert_nil adventure.current_clue_id
    assert adventure.ensure_current_clue!
    assert_not_nil adventure.current_clue_id
  end

  test "ensure_current_clue! returns false for completed adventures" do
    adventure = Adventure.create!(@valid_attributes.merge(status: :completed))
    adventure.update_column(:current_clue_id, nil)
    adventure.reload

    assert_not adventure.ensure_current_clue!
    assert_nil adventure.current_clue_id
  end

  test "ensure_current_clue! skips already solved clues" do
    adventure = Adventure.create!(@valid_attributes.merge(solved_clue_ids: [ @clue1.id ]))
    adventure.update_column(:current_clue_id, nil)
    adventure.reload

    assert adventure.ensure_current_clue!
    assert_equal @clue2.id, adventure.current_clue_id
  end

  # Solved Clue IDs Tests
  test "should have empty solved_clue_ids array by default" do
    adventure = Adventure.new(@valid_attributes)
    assert_equal [], adventure.solved_clue_ids
  end

  test "should accept solved_clue_ids as array" do
    adventure = Adventure.create!(@valid_attributes.merge(solved_clue_ids: [ @clue1.id ]))
    assert_equal [ @clue1.id ], adventure.solved_clue_ids
  end

  test "should allow modifying solved_clue_ids" do
    adventure = Adventure.create!(@valid_attributes)
    adventure.solved_clue_ids << @clue1.id
    adventure.save!
    adventure.reload
    assert_includes adventure.solved_clue_ids, @clue1.id
  end

  # Multiple Adventures Tests
  test "should allow user to have completed adventures for same hunt" do
    initial_count = @user.adventures.where(hunt: @hunt, status: :completed).count
    adventure1 = Adventure.create!(@valid_attributes.merge(status: :completed))
    adventure2 = Adventure.create!(@valid_attributes.merge(status: :completed))

    assert_equal initial_count + 2, @user.adventures.where(hunt: @hunt, status: :completed).count
  end

  test "should allow user to have both in_progress and completed adventures" do
    initial_completed = @user.adventures.where(hunt: @hunt, status: :completed).count
    completed = Adventure.create!(@valid_attributes.merge(status: :completed))
    in_progress = Adventure.create!(@valid_attributes.merge(status: :in_progress))

    assert_equal 1, @user.adventures.where(hunt: @hunt, status: :in_progress).count
    assert_equal initial_completed + 1, @user.adventures.where(hunt: @hunt, status: :completed).count
  end

  # Integration Tests
  test "should create adventure with all fields" do
    adventure = Adventure.create!(
      user: @user,
      hunt: @hunt,
      status: :in_progress,
      solved_clue_ids: [ @clue1.id ]
    )

    assert adventure.persisted?
    assert_equal @user, adventure.user
    assert_equal @hunt, adventure.hunt
    assert adventure.in_progress?
    assert_equal [ @clue1.id ], adventure.solved_clue_ids
  end

  test "should destroy adventure when user is destroyed" do
    adventure = Adventure.create!(@valid_attributes)
    adventure_id = adventure.id

    @user.destroy

    assert_raises(ActiveRecord::RecordNotFound) do
      Adventure.find(adventure_id)
    end
  end

  test "should destroy adventure when hunt is destroyed" do
    adventure = Adventure.create!(@valid_attributes)
    adventure_id = adventure.id

    @hunt.destroy

    assert_raises(ActiveRecord::RecordNotFound) do
      Adventure.find(adventure_id)
    end
  end

  # All Clues Solved Tests
  test "should return false when clues are not all solved" do
    adventure = Adventure.create!(@valid_attributes.merge(
      solved_clue_ids: [ @clue1.id ]
    ))

    assert_not adventure.all_clues_solved?
  end

  test "should return true when all clues are solved" do
    adventure = Adventure.create!(@valid_attributes.merge(
      solved_clue_ids: [ @clue1.id, @clue2.id ],
      status: :completed
    ))

    assert adventure.all_clues_solved?
  end

  test "should return false when no clues are solved" do
    adventure = Adventure.create!(@valid_attributes.merge(
      solved_clue_ids: []
    ))

    assert_not adventure.all_clues_solved?
  end

  # Solve Current Clue Tests
  test "should solve current clue and add to solved_clue_ids" do
    adventure = Adventure.create!(@valid_attributes.merge(
      solved_clue_ids: []
    ))
    adventure.reload
    current_clue_id = adventure.current_clue_id
    assert_not_nil current_clue_id

    assert adventure.solve_current_clue!
    adventure.reload

    assert_includes adventure.solved_clue_ids, current_clue_id
  end

  test "should not change status when not all clues solved" do
    adventure = Adventure.create!(@valid_attributes.merge(
      solved_clue_ids: []
    ))

    adventure.solve_current_clue!
    adventure.reload

    assert adventure.in_progress?
  end

  test "should change status to completed when all clues solved" do
    adventure = Adventure.create!(@valid_attributes.merge(
      solved_clue_ids: [ @clue1.id ]
    ))
    adventure.reload
    # current_clue should be @clue2 since @clue1 is already solved
    assert_equal @clue2.id, adventure.current_clue_id

    adventure.solve_current_clue!
    adventure.reload

    assert adventure.completed?
  end

  test "should return false when no current clue to solve" do
    adventure = Adventure.create!(@valid_attributes.merge(
      solved_clue_ids: [ @clue1.id, @clue2.id ],
      status: :completed
    ))
    # current_clue_id should be nil since all clues are solved
    adventure.update_column(:current_clue_id, nil)
    adventure.reload

    assert_not adventure.solve_current_clue!
  end

  test "should solve clues in order" do
    adventure = Adventure.create!(@valid_attributes.merge(
      solved_clue_ids: []
    ))
    adventure.reload

    first_clue_id = adventure.current_clue_id
    assert_not_nil first_clue_id

    # Solve first clue
    assert adventure.solve_current_clue!
    adventure.reload
    assert_includes adventure.solved_clue_ids, first_clue_id

    second_clue_id = adventure.current_clue_id
    assert_not_nil second_clue_id
    assert_not_equal first_clue_id, second_clue_id

    # Solve second clue
    assert adventure.solve_current_clue!
    adventure.reload
    assert_includes adventure.solved_clue_ids, second_clue_id
    assert_nil adventure.current_clue
    assert adventure.completed?
  end
end
