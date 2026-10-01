require "test_helper"

class TeamMembershipTest < ActiveSupport::TestCase
  test "validates user uniqueness (one team per user)" do
    user = users(:regular_user)
    other_team = teams(:solo_team)
    membership = TeamMembership.new(team: other_team, user: user)
    assert_not membership.valid?
    assert_includes membership.errors[:user_id], "is already in a team"
  end

  test "allows different users in same team" do
    team = teams(:ruby_hunters)
    new_user = User.create!(email: "new@test.io", password: "password123")
    membership = TeamMembership.new(team: team, user: new_user)
    assert membership.valid?
  end
end
