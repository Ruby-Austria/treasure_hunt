require "test_helper"

class HuntsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular_user)
    @approved_hunt = hunts(:one)
    @draft_hunt = hunts(:two)

    @approved_hunt.update!(status: :approved)
    @draft_hunt.update!(status: :draft)
  end

  # Show Tests
  test "show is accessible without authentication for approved hunt" do
    get hunt_url(@approved_hunt)
    assert_response :success
    assert_match @approved_hunt.name, response.body
  end

  test "unauthenticated user sees login link on hunt page" do
    get hunt_url(@approved_hunt)
    assert_response :success
    assert_match "Log in to begin", response.body
  end

  test "should get show when authenticated and hunt is approved" do
    post login_url, params: { email: @user.email, password: "password123" }
    get hunt_url(@approved_hunt)
    assert_response :success
    assert_match @approved_hunt.name, response.body
  end

  test "should redirect to root if hunt is not approved" do
    get hunt_url(@draft_hunt)
    assert_redirected_to root_url
    assert_equal "Hunt not found or not available.", flash[:alert]
  end

  test "should redirect to root if hunt does not exist" do
    get hunt_url(id: 99999)
    assert_redirected_to root_url
    assert_equal "Hunt not found or not available.", flash[:alert]
  end

  test "should display hunt details on show page" do
    get hunt_url(@approved_hunt)
    assert_response :success

    assert_match @approved_hunt.name, response.body
    # Difficulty removed from user-facing UI (PRD-0008)
    assert_no_match(/Easy|Moderate|Medium|Challenging|Hard/, response.body)

    if @approved_hunt.description.present?
      assert_match @approved_hunt.description, response.body
    end
  end

  # Index route removed (PRD-0002)
  test "index route does not exist" do
    get "/hunts"
    assert_response :not_found
  end
end
