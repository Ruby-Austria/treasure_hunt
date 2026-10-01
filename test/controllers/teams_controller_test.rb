require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:admin_user)
    post login_url, params: { email: @user.email, password: "password123" }
  end

  test "new renders create/join form" do
    get new_team_url
    assert_response :success
    assert_match "Create a team", response.body
    assert_match "Join with code", response.body
  end

  test "new redirects to team if already in one" do
    team = Team.create!(name: "Test Team")
    team.members << @user
    get new_team_url
    assert_redirected_to team_url
  end

  test "create creates team and adds creator as member" do
    assert_difference [ "Team.count", "TeamMembership.count" ], 1 do
      post team_url, params: { team: { name: "New Team" } }
    end
    assert_redirected_to team_url
    assert_equal "New Team", @user.reload.team.name
  end

  test "create rejects blank name" do
    assert_no_difference "Team.count" do
      post team_url, params: { team: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "create rejects if already in team" do
    team = Team.create!(name: "Existing")
    team.members << @user
    assert_no_difference "Team.count" do
      post team_url, params: { team: { name: "Another" } }
    end
    assert_redirected_to team_url
  end

  test "join adds user to team by invite code" do
    team = Team.create!(name: "Joinable")
    assert_difference "TeamMembership.count", 1 do
      post join_team_url, params: { invite_code: team.invite_code }
    end
    assert_redirected_to team_url
    assert_equal team, @user.reload.team
  end

  test "join rejects invalid code" do
    post join_team_url, params: { invite_code: "WRONG1" }
    assert_redirected_to new_team_url
    assert_match "Invalid invite code", flash[:alert]
  end

  test "join rejects if already in team" do
    team = Team.create!(name: "First")
    team.members << @user
    other = Team.create!(name: "Second")
    post join_team_url, params: { invite_code: other.invite_code }
    assert_redirected_to team_url
    assert_equal team, @user.reload.team
  end

  test "show displays team info" do
    team = Team.create!(name: "Show Team")
    team.members << @user
    get team_url
    assert_response :success
    assert_match "Show Team", response.body
    assert_match team.invite_code, response.body
  end

  test "leave removes user from team" do
    # Use a fresh user with no completed adventures
    fresh = User.create!(email: "leaver@test.io", password: "password123")
    delete logout_url
    post login_url, params: { email: fresh.email, password: "password123" }

    team = Team.create!(name: "Leave Team")
    team.members << fresh
    assert_difference "TeamMembership.count", -1 do
      delete leave_team_url
    end
    assert_redirected_to dashboard_url
    assert_nil fresh.reload.team
  end

  test "leave deletes team if last member" do
    fresh = User.create!(email: "deleter@test.io", password: "password123")
    delete logout_url
    post login_url, params: { email: fresh.email, password: "password123" }

    team = Team.create!(name: "Delete Team")
    team.members << fresh
    assert_difference [ "Team.count", "TeamMembership.count" ], -1 do
      delete leave_team_url
    end
  end

  test "leave blocked when team has completed adventures" do
    team = Team.create!(name: "Completed Team")
    team.members << @user
    hunt = hunts(:approved_hunt)
    Adventure.create!(user: @user, hunt: hunt, status: :completed)
    assert_no_difference "TeamMembership.count" do
      delete leave_team_url
    end
    assert_redirected_to team_url
    assert_match "cannot leave", flash[:alert]
  end

  test "regenerate_code changes invite code" do
    team = Team.create!(name: "Regen Team")
    team.members << @user
    old_code = team.invite_code
    post regenerate_code_team_url
    assert_not_equal old_code, team.reload.invite_code
    assert_redirected_to team_url
  end

  test "requires login" do
    delete logout_url
    get new_team_url
    assert_redirected_to login_url
  end
end
