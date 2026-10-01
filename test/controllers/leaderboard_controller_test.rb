require "test_helper"

class LeaderboardControllerTest < ActionDispatch::IntegrationTest
  test "leaderboard is publicly accessible" do
    get leaderboard_url
    assert_response :success
    assert_match "Leaderboard", response.body
  end

  test "leaderboard shows hunt names" do
    hunt = Hunt.create!(name: "Public Hunt", status: :approved, difficulty: :easy, hunt_type: :for_fun, price: 0, language: "en")
    location = locations(:one)
    Clue.create!(hunt: hunt, location: location, description: "Find it", difficulty: :easy)
    get leaderboard_url
    assert_response :success
    assert_match "Public Hunt", response.body
  end

  test "leaderboard shows team entries" do
    hunt = Hunt.create!(name: "Team Hunt", status: :approved, difficulty: :easy, hunt_type: :for_fun, price: 0, language: "en")
    location = locations(:one)
    clue = Clue.create!(hunt: hunt, location: location, description: "Find it", difficulty: :easy)

    team = Team.create!(name: "Leaderboard Team")
    user = User.create!(email: "lb@test.io", password: "password123")
    team.members << user
    Adventure.create!(user: user, hunt: hunt, status: :in_progress, current_clue_id: clue.id)

    get leaderboard_url
    assert_match "Leaderboard Team", response.body
  end

  test "leaderboard shows solo players" do
    hunt = Hunt.create!(name: "Solo Hunt", status: :approved, difficulty: :easy, hunt_type: :for_fun, price: 0, language: "en")
    location = locations(:one)
    clue = Clue.create!(hunt: hunt, location: location, description: "Find it", difficulty: :easy)

    user = User.create!(email: "solo_lb@test.io", password: "password123")
    Adventure.create!(user: user, hunt: hunt, status: :in_progress, current_clue_id: clue.id)

    get leaderboard_url
    assert_match "solo_lb", response.body
    assert_no_match(/@test\.io/, response.body)
  end
end
