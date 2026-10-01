require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirects to login when not authenticated" do
    get dashboard_url
    assert_redirected_to login_url
  end

  test "shows dashboard when authenticated" do
    post login_url, params: { email: users(:regular_user).email, password: "password123" }
    get dashboard_url
    assert_response :success
  end

  test "shows team info when user has a team" do
    user = users(:regular_user)
    post login_url, params: { email: user.email, password: "password123" }
    get dashboard_url
    assert_response :success
    assert_match user.team.name, response.body
  end

  test "shows solo CTA when user has no team" do
    user = User.create!(email: "solo@test.io", password: "password123")
    post login_url, params: { email: user.email, password: "password123" }
    get dashboard_url
    assert_response :success
    assert_match "Join crew", response.body
  end
end
