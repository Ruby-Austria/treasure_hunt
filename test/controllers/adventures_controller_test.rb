require "test_helper"

class AdventuresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular_user)
    @other_user = users(:admin_user)
    @hunt = hunts(:two)
    @hunt.update!(status: :approved)

    # Ensure hunt is free and has clues
    @hunt.update!(price: 0.0)
    @location = locations(:one)
    @clue = Clue.find_or_create_by!(hunt: @hunt, location: @location) { |c| c.difficulty = :easy }

    # Clear any existing in_progress adventures for this user/hunt
    @user.adventures.where(hunt: @hunt, status: :in_progress).destroy_all
  end

  # Authentication Tests
  test "should redirect to login if not authenticated for create" do
    post hunt_adventures_path(@hunt)
    assert_redirected_to login_url
  end

  test "should redirect to login for show if not authenticated" do
    adventure = adventures(:one)
    get adventure_path(adventure)
    assert_redirected_to login_url
  end

  # Create Tests
  test "should create adventure when authenticated" do
    post login_url, params: { email: @user.email, password: "password123" }

    assert_difference("Adventure.count") do
      post hunt_adventures_path(@hunt)
    end

    adventure = Adventure.last
    assert_equal @user, adventure.user
    assert_equal @hunt, adventure.hunt
    assert adventure.in_progress?
    assert_redirected_to adventure_path(adventure)
    assert_equal "Adventure started! Good luck!", flash[:notice]
  end

  test "should redirect to existing in_progress adventure instead of creating new one" do
    post login_url, params: { email: @user.email, password: "password123" }

    # Create first adventure
    post hunt_adventures_path(@hunt)
    first_adventure = Adventure.last

    # Try to create second - should redirect to existing
    assert_no_difference("Adventure.count") do
      post hunt_adventures_path(@hunt)
    end

    assert_redirected_to adventure_path(first_adventure)
    assert_equal "You already have an active adventure for this hunt!", flash[:notice]
  end

  test "should create new adventure after previous one is completed" do
    post login_url, params: { email: @user.email, password: "password123" }

    # Create and complete first adventure
    existing_adventure = Adventure.create!(
      user: @user,
      hunt: @hunt,
      status: :completed
    )

    # Should allow new adventure
    assert_difference("Adventure.count") do
      post hunt_adventures_path(@hunt)
    end

    new_adventure = Adventure.last
    assert_not_equal existing_adventure.id, new_adventure.id
    assert new_adventure.in_progress?
  end

  test "should set current_clue when creating adventure" do
    post login_url, params: { email: @user.email, password: "password123" }
    post hunt_adventures_path(@hunt)

    adventure = Adventure.last
    adventure.reload
    assert_not_nil adventure.current_clue_id
    assert_includes @hunt.clues.pluck(:id), adventure.current_clue_id
  end

  test "should not create adventure for hunt with no clues" do
    # Create an approved hunt with no clues
    empty_hunt = Hunt.create!(name: "Empty Hunt", difficulty: :easy, hunt_type: :for_fun, status: :approved)

    post login_url, params: { email: @user.email, password: "password123" }

    assert_no_difference("Adventure.count") do
      post hunt_adventures_path(empty_hunt)
    end

    assert_redirected_to hunt_path(empty_hunt)
    assert_equal "This hunt has no clues yet and cannot be started.", flash[:alert]
  end

  test "should not create adventure for non-approved hunt" do
    draft_hunt = hunts(:one)
    draft_hunt.update!(status: :draft)

    post login_url, params: { email: @user.email, password: "password123" }

    assert_no_difference("Adventure.count") do
      post hunt_adventures_path(draft_hunt)
    end
  end

  # Show Tests
  test "should get show when authenticated and adventure belongs to user" do
    post login_url, params: { email: @user.email, password: "password123" }
    adventure = Adventure.create!(
      user: @user,
      hunt: @hunt,
      status: :in_progress
    )

    get adventure_path(adventure)
    assert_response :success
    assert_match adventure.hunt.name, response.body
  end

  test "should return 404 if adventure belongs to different user" do
    post login_url, params: { email: @user.email, password: "password123" }
    @other_user.adventures.where(hunt: @hunt, status: :in_progress).destroy_all
    adventure = Adventure.create!(
      user: @other_user,
      hunt: @hunt,
      status: :in_progress
    )

    get adventure_path(adventure)
    assert_response :not_found
  end

  test "should display adventure status on show page" do
    post login_url, params: { email: @user.email, password: "password123" }
    adventure = Adventure.create!(
      user: @user,
      hunt: @hunt,
      status: :in_progress
    )

    get adventure_path(adventure)
    assert_response :success
  end

  # Check Location Tests
  test "should redirect to login for check_location if not authenticated" do
    adventure = Adventure.create!(
      user: @user,
      hunt: @hunt,
      status: :in_progress
    )
    post check_location_adventure_path(adventure), params: { latitude: 40.7128, longitude: -74.0060, accuracy: 10 }
    assert_redirected_to login_url
  end

  test "should check location when authenticated" do
    post login_url, params: { email: @user.email, password: "password123" }
    adventure = Adventure.create!(
      user: @user,
      hunt: @hunt,
      status: :in_progress
    )
    adventure.reload

    # Get clue location
    current_clue = adventure.current_clue
    clue_location = current_clue.location

    post check_location_adventure_path(adventure),
         params: { latitude: clue_location.lat, longitude: clue_location.long, accuracy: 10 },
         as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response.key?("can_claim")
  end

  test "should not allow check_location for other user's adventure" do
    post login_url, params: { email: @user.email, password: "password123" }
    @other_user.adventures.where(hunt: @hunt, status: :in_progress).destroy_all
    adventure = Adventure.create!(
      user: @other_user,
      hunt: @hunt,
      status: :in_progress
    )

    post check_location_adventure_path(adventure),
         params: { latitude: 40.7128, longitude: -74.0060, accuracy: 10 },
         as: :json

    assert_response :not_found
  end

  test "should return error if no current clue to solve" do
    post login_url, params: { email: @user.email, password: "password123" }
    adventure = Adventure.create!(
      user: @user,
      hunt: @hunt,
      status: :in_progress
    )
    # Remove current_clue to simulate no clue to solve
    adventure.update_column(:current_clue_id, nil)

    post check_location_adventure_path(adventure),
         params: { latitude: 40.7128, longitude: -74.0060, accuracy: 10 },
         as: :json

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "No clue to solve", json_response["error"]
  end

  # Payment gate removed (PRD-0002: all hunts free for conference)

  # Abandon Tests
  test "should abandon in_progress adventure" do
    post login_url, params: { email: @user.email, password: "password123" }
    adventure = Adventure.create!(user: @user, hunt: @hunt, status: :in_progress)

    delete abandon_adventure_path(adventure)

    adventure.reload
    assert adventure.abandoned?
    assert_nil adventure.current_clue_id
    assert_redirected_to hunt_path(@hunt)
  end

  test "should not abandon completed adventure" do
    post login_url, params: { email: @user.email, password: "password123" }
    adventure = Adventure.create!(user: @user, hunt: @hunt, status: :completed)

    delete abandon_adventure_path(adventure)

    adventure.reload
    assert adventure.completed?
    assert_redirected_to adventure_path(adventure)
  end

  # Claim Clue Tests
  test "should redirect to login for claim_clue if not authenticated" do
    adventure = Adventure.create!(
      user: @user,
      hunt: @hunt,
      status: :in_progress
    )
    post claim_clue_adventure_path(adventure)
    assert_redirected_to login_url
  end

  test "should not allow claim_clue for other user's adventure" do
    post login_url, params: { email: @user.email, password: "password123" }
    @other_user.adventures.where(hunt: @hunt, status: :in_progress).destroy_all
    adventure = Adventure.create!(
      user: @other_user,
      hunt: @hunt,
      status: :in_progress
    )

    post claim_clue_adventure_path(adventure), as: :json

    assert_response :not_found
  end
end
