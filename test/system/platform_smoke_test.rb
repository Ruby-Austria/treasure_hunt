require "application_system_test_case"

class PlatformSmokeTest < ApplicationSystemTestCase
  setup do
    @admin = users(:admin_user)
    @user = users(:regular_user)
  end

  test "landing page loads with conference branding" do
    visit root_url
    assert_selector "h1", text: "Hunt for treasure"
    assert_text "RubyConf Austria"
  end

  test "login page renders correctly" do
    visit login_url
    assert_selector "h1", text: "Sign in."
    assert_selector "input[type='email']"
    assert_selector "input[type='password']"
    assert_selector "input[type='submit']"
  end

  test "user can log in and see landing page" do
    log_in_as @user.email
    assert_text "Welcome back!"
  end

  test "logged in user sees nav bar with logout" do
    log_in_as @user.email

    assert_selector "nav"
    assert_selector "button", text: "Logout"
  end

  test "admin can access admin dashboard" do
    log_in_as @admin.email

    click_on "Admin"
    assert_current_path admin_root_path
    assert_selector "h2", text: "Dashboard"
    assert_text "Total Users"
    assert_text "Total Hunts"
    assert_text "Total Locations"
  end

  test "admin can navigate admin panel" do
    log_in_as @admin.email
    click_on "Admin"
    assert_current_path admin_root_path

    click_on "Locations"
    assert_current_path admin_locations_path
    assert_selector "h2", text: "Locations"

    click_on "Hunts"
    assert_current_path admin_hunts_path
    assert_selector "h2", text: "Hunts"

    click_on "Clues"
    assert_current_path admin_clues_path
    assert_selector "h2", text: "Clues"
  end

  test "non-admin cannot access admin" do
    log_in_as @user.email
    assert_text "Welcome back!"

    visit admin_root_url
    assert_text "You must be an admin"
  end

  test "user can logout" do
    log_in_as @user.email

    click_on "Logout"
    assert_current_path root_path
    assert_text "Logged out successfully"
  end

  test "invalid login shows error" do
    visit login_url
    fill_in "Email", with: @user.email
    fill_in "Password", with: "wrongpassword"
    find("input[type='submit']").click

    assert_text "Invalid email or password"
  end

  private

  def log_in_as(email, password: "password123")
    visit login_url
    fill_in "Email", with: email
    fill_in "Password", with: password
    find("input[type='submit']").click
  end
end
