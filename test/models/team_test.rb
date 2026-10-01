require "test_helper"

class TeamTest < ActiveSupport::TestCase
  test "validates name presence" do
    team = Team.new(name: nil)
    assert_not team.valid?
    assert_includes team.errors[:name], "can't be blank"
  end

  test "validates name uniqueness" do
    team = Team.new(name: teams(:ruby_hunters).name)
    assert_not team.valid?
    assert_includes team.errors[:name], "has already been taken"
  end

  test "validates name max length" do
    team = Team.new(name: "a" * 51)
    assert_not team.valid?
  end

  test "generates invite code on create" do
    team = Team.create!(name: "New Team")
    assert_not_nil team.invite_code
    assert_equal 6, team.invite_code.length
    assert_match(/\A[A-Z0-9]{6}\z/, team.invite_code)
  end

  test "regenerate_invite_code! changes the code" do
    team = teams(:ruby_hunters)
    old_code = team.invite_code
    team.regenerate_invite_code!
    assert_not_equal old_code, team.invite_code
  end

  test "has_completed_adventures? returns true when member has completed adventure" do
    team = teams(:ruby_hunters)
    user = team.members.first
    hunt = hunts(:approved_hunt)
    Adventure.create!(user: user, hunt: hunt, status: :completed)
    assert team.has_completed_adventures?
  end

  test "has_completed_adventures? returns false when no completed adventures" do
    team = teams(:solo_team)
    new_user = User.create!(email: "solo_test@test.io", password: "password123")
    team.members << new_user
    assert_not team.has_completed_adventures?
  end

  test "destroying team destroys memberships" do
    team = teams(:ruby_hunters)
    assert_difference "TeamMembership.count", -1 do
      team.destroy
    end
  end
end
