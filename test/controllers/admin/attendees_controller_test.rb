require "test_helper"

class Admin::AttendeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    post login_url, params: { email: @admin.email, password: "password123" }
  end

  test "index shows attendees" do
    get admin_attendees_url
    assert_response :success
    assert_match "Attendees", response.body
  end

  test "new renders form" do
    get new_admin_attendee_url
    assert_response :success
    assert_match "Add Attendee", response.body
  end

  test "create adds attendee with auto-generated password" do
    assert_difference("User.count") do
      post admin_attendees_url, params: { user: { email: "attendee@rubyconf.at" } }
    end

    assert_redirected_to admin_attendees_url
    assert_match "attendee@rubyconf.at", flash[:notice]
    assert_match "Password:", flash[:notice]

    user = User.find_by(email: "attendee@rubyconf.at")
    assert_not user.admin?
  end

  test "create with invalid email shows errors" do
    assert_no_difference("User.count") do
      post admin_attendees_url, params: { user: { email: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "destroy removes attendee" do
    attendee = User.create!(email: "remove@rubyconf.at", password: "password123")

    assert_difference("User.count", -1) do
      delete admin_attendee_url(attendee)
    end

    assert_redirected_to admin_attendees_url
  end

  test "destroy prevents deleting admin users" do
    assert_no_difference("User.count") do
      delete admin_attendee_url(@admin)
    end

    assert_redirected_to admin_attendees_url
    assert_match "Cannot delete admin", flash[:alert]
  end

  test "bulk_new renders form" do
    get bulk_new_admin_attendees_url
    assert_response :success
    assert_match "Bulk Import", response.body
  end

  test "bulk_create creates multiple attendees" do
    emails = "one@rubyconf.at\ntwo@rubyconf.at\nthree@rubyconf.at"

    assert_difference("User.count", 3) do
      post bulk_create_admin_attendees_url, params: { emails: emails }
    end

    assert_response :success
    assert_match "one@rubyconf.at", response.body
    assert_match "two@rubyconf.at", response.body
    assert_match "three@rubyconf.at", response.body
  end

  test "bulk_create handles duplicates and invalid emails" do
    User.create!(email: "existing@rubyconf.at", password: "password123")
    emails = "existing@rubyconf.at\nnew@rubyconf.at"

    assert_difference("User.count", 1) do
      post bulk_create_admin_attendees_url, params: { emails: emails }
    end

    assert_response :success
    assert_match "Errors", response.body
  end

  test "non-admin cannot access attendees" do
    delete logout_url
    user = users(:regular_user)
    post login_url, params: { email: user.email, password: "password123" }

    get admin_attendees_url
    assert_redirected_to root_url
  end
end
