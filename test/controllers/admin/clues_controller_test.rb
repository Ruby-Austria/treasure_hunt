require "test_helper"

class Admin::CluesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin_user)
    @regular_user = users(:regular_user)
    @clue = clues(:one)
    @hunt = hunts(:one)
    @location = locations(:one)
    @location2 = locations(:two)
  end

  # Authentication Tests
  test "should redirect to login if not authenticated" do
    get admin_clues_url
    assert_redirected_to login_url
  end

  test "should redirect non-admin users" do
    post login_url, params: { email: @regular_user.email, password: "password123" }
    get admin_clues_url
    assert_redirected_to root_url
    assert_equal "You must be an admin to access this page.", flash[:alert]
  end

  # Index Tests
  test "should get index when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    get admin_clues_url
    assert_response :success
  end

  test "should list all clues" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    get admin_clues_url
    assert_response :success
    assert_select "table" do
      assert_select "tr", minimum: 2 # Header + at least one clue
    end
  end

  # Show Tests
  test "should get show when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    get admin_clue_url(@clue)
    assert_response :success
    assert_match @clue.description, response.body
  end

  test "should redirect show if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }
    get admin_clue_url(@clue)
    assert_redirected_to root_url
  end

  # New Tests
  test "should get new when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    get new_admin_clue_url
    assert_response :success
    assert_select "form"
  end

  test "should redirect new if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }
    get new_admin_clue_url
    assert_redirected_to root_url
  end

  # Create Tests
  test "should create clue when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_difference("Clue.count") do
      post admin_clues_url, params: {
        clue: {
          hunt_id: @hunt.id,
          location_id: @location2.id,
          description: "Test clue description",
          difficulty: "easy",
          reasoning: "Test reasoning"
        }
      }
    end

    assert_redirected_to admin_clue_path(Clue.last)
    assert_equal "Clue was successfully created.", flash[:notice]
  end

  test "should not create clue with invalid data" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_no_difference("Clue.count") do
      post admin_clues_url, params: {
        clue: {
          hunt_id: @hunt.id,
          location_id: @location2.id,
          difficulty: "" # Missing difficulty
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should enforce uniqueness of hunt and location combination" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    # Create first clue
    post admin_clues_url, params: {
      clue: {
        hunt_id: @hunt.id,
        location_id: @location.id,
        difficulty: "easy"
      }
    }

    # Try to create duplicate
    assert_no_difference("Clue.count") do
      post admin_clues_url, params: {
        clue: {
          hunt_id: @hunt.id,
          location_id: @location.id,
          difficulty: "moderate"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should allow same location in different hunts" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    hunt2 = hunts(:two)

    # Use location2 which has no fixture clues to avoid conflicts
    # Create clue for hunt 1
    post admin_clues_url, params: {
      clue: {
        hunt_id: @hunt.id,
        location_id: @location2.id,
        difficulty: "easy"
      }
    }

    # Create clue for hunt 2 with same location
    assert_difference("Clue.count") do
      post admin_clues_url, params: {
        clue: {
          hunt_id: hunt2.id,
          location_id: @location2.id,
          difficulty: "hard"
        }
      }
    end

    assert_redirected_to admin_clue_path(Clue.last)
  end

  test "should allow different locations in same hunt" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    # Create clue for location 1
    post admin_clues_url, params: {
      clue: {
        hunt_id: @hunt.id,
        location_id: @location.id,
        difficulty: "easy"
      }
    }

    # Create clue for location 2 in same hunt
    assert_difference("Clue.count") do
      post admin_clues_url, params: {
        clue: {
          hunt_id: @hunt.id,
          location_id: @location2.id,
          difficulty: "moderate"
        }
      }
    end

    assert_redirected_to admin_clue_path(Clue.last)
  end

  test "should redirect create if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }

    assert_no_difference("Clue.count") do
      post admin_clues_url, params: {
        clue: {
          hunt_id: @hunt.id,
          location_id: @location.id,
          difficulty: "easy"
        }
      }
    end

    assert_redirected_to root_url
  end

  # Edit Tests
  test "should get edit when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    get edit_admin_clue_url(@clue)
    assert_response :success
    assert_select "form"
    assert_match @clue.description, response.body
  end

  test "should redirect edit if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }
    get edit_admin_clue_url(@clue)
    assert_redirected_to root_url
  end

  # Update Tests
  test "should update clue when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    patch admin_clue_url(@clue), params: {
      clue: {
        hunt_id: @clue.hunt_id,
        location_id: @clue.location_id,
        description: "Updated clue description",
        difficulty: @clue.difficulty,
        reasoning: "Updated reasoning"
      }
    }

    assert_redirected_to admin_clue_path(@clue)
    assert_equal "Clue was successfully updated.", flash[:notice]
    @clue.reload
    assert_equal "Updated clue description", @clue.description
    assert_equal "Updated reasoning", @clue.reasoning
  end

  test "should not update clue with invalid data" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    original_description = @clue.description

    patch admin_clue_url(@clue), params: {
      clue: {
        hunt_id: @clue.hunt_id,
        location_id: @clue.location_id,
        difficulty: "" # Invalid difficulty
      }
    }

    assert_response :unprocessable_entity
    @clue.reload
    assert_equal original_description, @clue.description
  end

  test "should not allow updating to duplicate hunt-location combination" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    # Create another clue with different hunt-location
    clue2 = Clue.create!(
      hunt: hunts(:two),
      location: @location2,
      difficulty: :easy
    )

    # Try to update clue2 to have same hunt-location as clue1
    patch admin_clue_url(clue2), params: {
      clue: {
        hunt_id: @clue.hunt_id,
        location_id: @clue.location_id,
        difficulty: clue2.difficulty
      }
    }

    assert_response :unprocessable_entity
    clue2.reload
    assert_not_equal @clue.hunt_id, clue2.hunt_id
  end

  test "should redirect update if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }
    original_description = @clue.description

    patch admin_clue_url(@clue), params: {
      clue: {
        hunt_id: @clue.hunt_id,
        location_id: @clue.location_id,
        description: "Hacked description",
        difficulty: @clue.difficulty
      }
    }

    assert_redirected_to root_url
    @clue.reload
    assert_equal original_description, @clue.description
  end

  # Destroy Tests
  test "should destroy clue when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_difference("Clue.count", -1) do
      delete admin_clue_url(@clue)
    end

    assert_redirected_to admin_clues_path
    assert_equal "Clue was successfully deleted.", flash[:notice]
  end

  test "should redirect destroy if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }

    assert_no_difference("Clue.count") do
      delete admin_clue_url(@clue)
    end

    assert_redirected_to root_url
  end

  # Validation Tests
  test "should require hunt_id" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_no_difference("Clue.count") do
      post admin_clues_url, params: {
        clue: {
          location_id: @location.id,
          difficulty: "easy"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should require location_id" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_no_difference("Clue.count") do
      post admin_clues_url, params: {
        clue: {
          hunt_id: @hunt.id,
          difficulty: "easy"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should require difficulty" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_no_difference("Clue.count") do
      post admin_clues_url, params: {
        clue: {
          hunt_id: @hunt.id,
          location_id: @location.id
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should accept valid enum values for difficulty" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_difference("Clue.count") do
      post admin_clues_url, params: {
        clue: {
          hunt_id: @hunt.id,
          location_id: @location2.id,
          difficulty: "hard"
        }
      }
    end

    clue = Clue.last
    assert_equal "hard", clue.difficulty
  end

  test "should handle optional description and reasoning fields" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_difference("Clue.count") do
      post admin_clues_url, params: {
        clue: {
          hunt_id: @hunt.id,
          location_id: @location2.id,
          difficulty: "easy"
          # No description or reasoning
        }
      }
    end

    clue = Clue.last
    assert_nil clue.description
    assert_nil clue.reasoning
  end

  test "should handle description and reasoning fields" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    post admin_clues_url, params: {
      clue: {
        hunt_id: @hunt.id,
        location_id: @location2.id,
        difficulty: "easy",
        description: "This is a detailed clue description",
        reasoning: "This is the reasoning for choosing this location"
      }
    }

    clue = Clue.last
    assert_equal "This is a detailed clue description", clue.description
    assert_equal "This is the reasoning for choosing this location", clue.reasoning
  end
end
