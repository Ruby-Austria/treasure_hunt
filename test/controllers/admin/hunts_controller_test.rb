require "test_helper"

class Admin::HuntsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin_user)
    @regular_user = users(:regular_user)
    @hunt = hunts(:one)
  end

  # Authentication Tests
  test "should redirect to login if not authenticated" do
    get admin_hunts_url
    assert_redirected_to login_url
  end

  test "should redirect non-admin users" do
    post login_url, params: { email: @regular_user.email, password: "password123" }
    get admin_hunts_url
    assert_redirected_to root_url
    assert_equal "You must be an admin to access this page.", flash[:alert]
  end

  # Index Tests
  test "should get index when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    get admin_hunts_url
    assert_response :success
  end

  test "should list all hunts" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    get admin_hunts_url
    assert_response :success
    assert_select "table" do
      assert_select "tr", minimum: 2 # Header + at least one hunt
    end
  end

  # Show Tests
  test "should get show when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    get admin_hunt_url(@hunt)
    assert_response :success
    assert_match @hunt.name, response.body
  end

  test "should redirect show if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }
    get admin_hunt_url(@hunt)
    assert_redirected_to root_url
  end

  # New Tests
  test "should get new when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    get new_admin_hunt_url
    assert_response :success
    assert_select "form"
  end

  test "should redirect new if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }
    get new_admin_hunt_url
    assert_redirected_to root_url
  end

  # Create Tests
  test "should create hunt when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_difference("Hunt.count") do
      post admin_hunts_url, params: {
        hunt: {
          name: "Test Hunt",
          description: "A test treasure hunt",
          status: "draft",
          difficulty: "easy",
          hunt_type: "for_fun",
          price: 0.0,
          language: "en",
          tag_list: "outdoor, adventure"
        }
      }
    end

    assert_redirected_to admin_hunt_path(Hunt.last)
    assert_equal "Hunt was successfully created.", flash[:notice]
  end

  test "should not create hunt with invalid data" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_no_difference("Hunt.count") do
      post admin_hunts_url, params: {
        hunt: {
          name: "",
          status: "draft",
          difficulty: "easy",
          hunt_type: "for_fun",
          price: 0.0,
          language: "en"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should convert comma-separated tags to array" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    post admin_hunts_url, params: {
      hunt: {
        name: "Test Hunt",
        status: "draft",
        difficulty: "easy",
        hunt_type: "for_fun",
        price: 0.0,
        language: "en",
        tag_list: "outdoor, adventure, family-friendly"
      }
    }

    hunt = Hunt.last
    assert_includes hunt.tag_list, "outdoor"
    assert_includes hunt.tag_list, "adventure"
    assert_includes hunt.tag_list, "family-friendly"
  end

  test "should redirect create if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }

    assert_no_difference("Hunt.count") do
      post admin_hunts_url, params: {
        hunt: {
          name: "Test Hunt",
          status: "draft",
          difficulty: "easy",
          hunt_type: "for_fun",
          price: 0.0,
          language: "en"
        }
      }
    end

    assert_redirected_to root_url
  end

  # Edit Tests
  test "should get edit when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    get edit_admin_hunt_url(@hunt)
    assert_response :success
    assert_select "form"
    assert_match @hunt.name, response.body
  end

  test "should redirect edit if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }
    get edit_admin_hunt_url(@hunt)
    assert_redirected_to root_url
  end

  # Update Tests
  test "should update hunt when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    patch admin_hunt_url(@hunt), params: {
      hunt: {
        name: "Updated Hunt Name",
        description: "Updated description",
        status: @hunt.status,
        difficulty: @hunt.difficulty,
        hunt_type: @hunt.hunt_type,
        price: @hunt.price,
        language: @hunt.language
      }
    }

    assert_redirected_to admin_hunt_path(@hunt)
    assert_equal "Hunt was successfully updated.", flash[:notice]
    @hunt.reload
    assert_equal "Updated Hunt Name", @hunt.name
    assert_equal "Updated description", @hunt.description
  end

  test "should not update hunt with invalid data" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    original_name = @hunt.name

    patch admin_hunt_url(@hunt), params: {
      hunt: {
        name: "",
        status: @hunt.status,
        difficulty: @hunt.difficulty,
        hunt_type: @hunt.hunt_type,
        price: @hunt.price,
        language: @hunt.language
      }
    }

    assert_response :unprocessable_entity
    @hunt.reload
    assert_equal original_name, @hunt.name
  end

  test "should update tags from comma-separated string" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    patch admin_hunt_url(@hunt), params: {
      hunt: {
        name: @hunt.name,
        status: @hunt.status,
        difficulty: @hunt.difficulty,
        hunt_type: @hunt.hunt_type,
        price: @hunt.price,
        language: @hunt.language,
        tag_list: "new, updated, tags"
      }
    }

    @hunt.reload
    assert_includes @hunt.tag_list, "new"
    assert_includes @hunt.tag_list, "updated"
    assert_includes @hunt.tag_list, "tags"
  end

  test "should redirect update if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }
    original_name = @hunt.name

    patch admin_hunt_url(@hunt), params: {
      hunt: {
        name: "Hacked Name",
        status: @hunt.status,
        difficulty: @hunt.difficulty,
        hunt_type: @hunt.hunt_type,
        price: @hunt.price,
        language: @hunt.language
      }
    }

    assert_redirected_to root_url
    @hunt.reload
    assert_equal original_name, @hunt.name
  end

  # Destroy Tests
  test "should destroy hunt when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_difference("Hunt.count", -1) do
      delete admin_hunt_url(@hunt)
    end

    assert_redirected_to admin_hunts_path
    assert_equal "Hunt was successfully deleted.", flash[:notice]
  end

  test "should redirect destroy if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }

    assert_no_difference("Hunt.count") do
      delete admin_hunt_url(@hunt)
    end

    assert_redirected_to root_url
  end

  # Validation Tests
  test "should validate price is greater than or equal to zero" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_no_difference("Hunt.count") do
      post admin_hunts_url, params: {
        hunt: {
          name: "Test",
          status: "draft",
          difficulty: "easy",
          hunt_type: "for_fun",
          price: -10,
          language: "en"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should accept valid enum values" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_difference("Hunt.count") do
      post admin_hunts_url, params: {
        hunt: {
          name: "Test Hunt",
          status: "approved",
          difficulty: "hard",
          hunt_type: "reward",
          price: 19.99,
          language: "en"
        }
      }
    end

    hunt = Hunt.last
    assert_equal "approved", hunt.status
    assert_equal "hard", hunt.difficulty
    assert_equal "reward", hunt.hunt_type
  end

  test "should handle description field" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    post admin_hunts_url, params: {
      hunt: {
        name: "Test Hunt",
        description: "This is a detailed description of the hunt",
        status: "draft",
        difficulty: "easy",
        hunt_type: "for_fun",
        price: 0.0,
        language: "en"
      }
    }

    hunt = Hunt.last
    assert_equal "This is a detailed description of the hunt", hunt.description
  end

  test "should handle empty tags" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    post admin_hunts_url, params: {
      hunt: {
        name: "Test Hunt",
        status: "draft",
        difficulty: "easy",
        hunt_type: "for_fun",
        price: 0.0,
        language: "en",
        tag_list: ""
      }
    }

    hunt = Hunt.last
    assert_equal [], hunt.tag_list.to_a
  end

  test "should handle language field" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    post admin_hunts_url, params: {
      hunt: {
        name: "French Hunt",
        status: "draft",
        difficulty: "easy",
        hunt_type: "for_fun",
        price: 0.0,
        language: "fr"
      }
    }

    hunt = Hunt.last
    assert_equal "fr", hunt.language
  end
end
