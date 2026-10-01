require "test_helper"

class Admin::LocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin_user)
    @regular_user = users(:regular_user)
    @location = locations(:one)
  end

  # Authentication Tests
  test "should redirect to login if not authenticated" do
    get admin_locations_url
    assert_redirected_to login_url
  end

  test "should redirect non-admin users" do
    post login_url, params: { email: @regular_user.email, password: "password123" }
    get admin_locations_url
    assert_redirected_to root_url
    assert_equal "You must be an admin to access this page.", flash[:alert]
  end

  # Index Tests
  test "should get index when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    get admin_locations_url
    assert_response :success
  end

  test "should list all locations" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    get admin_locations_url
    assert_response :success
    assert_select "table" do
      assert_select "tr", minimum: 2 # Header + at least one location
    end
  end

  # Show Tests
  test "should get show when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    get admin_location_url(@location)
    assert_response :success
    assert_match @location.name, response.body
  end

  test "should redirect show if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }
    get admin_location_url(@location)
    assert_redirected_to root_url
  end

  # New Tests
  test "should get new when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    get new_admin_location_url
    assert_response :success
    assert_select "form"
  end

  test "should redirect new if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }
    get new_admin_location_url
    assert_redirected_to root_url
  end

  # Create Tests
  test "should create location when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_difference("Location.count") do
      post admin_locations_url, params: {
        location: {
          name: "Test Location",
          lat: 40.7128,
          long: -74.0060,
          country: "USA",
          city: "New York",
          difficulty: "easy",
          unlock_radius: 50,
          tag_list: "test, sample"
        }
      }
    end

    assert_redirected_to admin_location_path(Location.last)
    assert_equal "Location was successfully created.", flash[:notice]
  end

  test "should not create location with invalid data" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_no_difference("Location.count") do
      post admin_locations_url, params: {
        location: {
          name: "",
          lat: 40.7128,
          long: -74.0060,
          country: "USA",
          city: "New York",
          difficulty: "easy"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should convert comma-separated tags to array" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    post admin_locations_url, params: {
      location: {
        name: "Test Location",
        lat: 40.7128,
        long: -74.0060,
        country: "USA",
        city: "New York",
        difficulty: "easy",
        tag_list: "outdoor, park, family-friendly"
      }
    }

    location = Location.last
    assert_includes location.tag_list, "outdoor"
    assert_includes location.tag_list, "park"
    assert_includes location.tag_list, "family-friendly"
  end

  test "should redirect create if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }

    assert_no_difference("Location.count") do
      post admin_locations_url, params: {
        location: {
          name: "Test Location",
          lat: 40.7128,
          long: -74.0060,
          country: "USA",
          city: "New York",
          difficulty: "easy"
        }
      }
    end

    assert_redirected_to root_url
  end

  # Edit Tests
  test "should get edit when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    get edit_admin_location_url(@location)
    assert_response :success
    assert_select "form"
    assert_match @location.name, response.body
  end

  test "should redirect edit if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }
    get edit_admin_location_url(@location)
    assert_redirected_to root_url
  end

  # Update Tests
  test "should update location when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    patch admin_location_url(@location), params: {
      location: {
        name: "Updated Location Name",
        lat: @location.lat,
        long: @location.long,
        country: @location.country,
        city: @location.city,
        difficulty: @location.difficulty
      }
    }

    assert_redirected_to admin_location_path(@location)
    assert_equal "Location was successfully updated.", flash[:notice]
    @location.reload
    assert_equal "Updated Location Name", @location.name
  end

  test "should not update location with invalid data" do
    post login_url, params: { email: @admin_user.email, password: "password123" }
    original_name = @location.name

    patch admin_location_url(@location), params: {
      location: {
        name: "",
        lat: @location.lat,
        long: @location.long,
        country: @location.country,
        city: @location.city,
        difficulty: @location.difficulty
      }
    }

    assert_response :unprocessable_entity
    @location.reload
    assert_equal original_name, @location.name
  end

  test "should redirect update if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }
    original_name = @location.name

    patch admin_location_url(@location), params: {
      location: {
        name: "Hacked Name",
        lat: @location.lat,
        long: @location.long,
        country: @location.country,
        city: @location.city,
        difficulty: @location.difficulty
      }
    }

    assert_redirected_to root_url
    @location.reload
    assert_equal original_name, @location.name
  end

  # Destroy Tests
  test "should destroy location when authenticated as admin" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_difference("Location.count", -1) do
      delete admin_location_url(@location)
    end

    assert_redirected_to admin_locations_path
    assert_equal "Location was successfully deleted.", flash[:notice]
  end

  test "should redirect destroy if not admin" do
    post login_url, params: { email: @regular_user.email, password: "password123" }

    assert_no_difference("Location.count") do
      delete admin_location_url(@location)
    end

    assert_redirected_to root_url
  end

  # Validation Tests
  test "should validate latitude range" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_no_difference("Location.count") do
      post admin_locations_url, params: {
        location: {
          name: "Test",
          lat: 91,
          long: -74.0060,
          country: "USA",
          city: "New York",
          difficulty: "easy"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should validate longitude range" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_no_difference("Location.count") do
      post admin_locations_url, params: {
        location: {
          name: "Test",
          lat: 40.7128,
          long: 181,
          country: "USA",
          city: "New York",
          difficulty: "easy"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should validate unlock_radius is positive" do
    post login_url, params: { email: @admin_user.email, password: "password123" }

    assert_no_difference("Location.count") do
      post admin_locations_url, params: {
        location: {
          name: "Test",
          lat: 40.7128,
          long: -74.0060,
          country: "USA",
          city: "New York",
          difficulty: "easy",
          unlock_radius: -10
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
