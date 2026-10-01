require "test_helper"

class Admin::TeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    post login_url, params: { email: @admin.email, password: "password123" }
  end

  test "index shows teams" do
    get admin_teams_url
    assert_response :success
    assert_match "Teams", response.body
  end

  test "show displays team details" do
    team = teams(:ruby_hunters)
    get admin_team_url(team)
    assert_response :success
    assert_match team.name, response.body
  end

  test "requires admin" do
    delete logout_url
    user = users(:regular_user)
    post login_url, params: { email: user.email, password: "password123" }
    get admin_teams_url
    assert_redirected_to root_url
  end
end
