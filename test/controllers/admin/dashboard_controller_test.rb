# frozen_string_literal: true

require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    @regular_user = users(:regular_user)
  end

  test "should redirect unauthenticated users to login" do
    get admin_root_path
    assert_redirected_to login_url
  end

  test "should redirect non-admin users to root" do
    post login_url, params: { email: @regular_user.email, password: "password123" }
    get admin_root_path
    assert_redirected_to root_url
  end

  test "should get index for admin users" do
    post login_url, params: { email: @admin.email, password: "password123" }
    get admin_root_path
    assert_response :success
  end

  test "should display user stats" do
    post login_url, params: { email: @admin.email, password: "password123" }
    get admin_root_path

    assert_response :success
    assert_match(/Total Users/, response.body)
    assert_match(/Admin Users/, response.body)
  end

  test "should display location stats" do
    post login_url, params: { email: @admin.email, password: "password123" }
    get admin_root_path

    assert_response :success
    assert_match(/Total Locations/, response.body)
    assert_match(/Unique Tags/, response.body)
  end

  test "should display hunt stats" do
    post login_url, params: { email: @admin.email, password: "password123" }
    get admin_root_path

    assert_response :success
    assert_match(/Total Hunts/, response.body)
    assert_match(/Draft/, response.body)
    assert_match(/Approved/, response.body)
    assert_match(/Archived/, response.body)
  end

  test "should display clue and adventure stats" do
    post login_url, params: { email: @admin.email, password: "password123" }
    get admin_root_path

    assert_response :success
    assert_match(/Total Clues/, response.body)
    assert_match(/Total Adventures/, response.body)
  end

  test "should display quick action links" do
    post login_url, params: { email: @admin.email, password: "password123" }
    get admin_root_path

    assert_response :success
    assert_match(/Create New Location/, response.body)
    assert_match(/Create New Hunt/, response.body)
    assert_match(/Create New Clue/, response.body)
  end
end
