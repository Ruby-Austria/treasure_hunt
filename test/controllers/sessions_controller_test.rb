require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new (login page)" do
    get login_url
    assert_response :success
  end

  test "should create session with valid credentials" do
    user = users(:regular_user)
    post login_url, params: { email: user.email, password: "password123" }
    assert_redirected_to dashboard_url
  end

  test "should not create session with invalid credentials" do
    post login_url, params: { email: "wrong@email.com", password: "wrong" }
    assert_response :unprocessable_entity
  end

  test "invalid login renders error message" do
    post login_url, params: { email: "wrong@email.com", password: "wrong" }
    assert_response :unprocessable_entity
    assert_match "Invalid email or password", response.body
  end

  test "successful login redirects with 303 see_other for Turbo" do
    user = users(:regular_user)
    post login_url, params: { email: user.email, password: "password123" }
    assert_response :see_other
    assert_redirected_to dashboard_url
  end

  test "login resets session to prevent session fixation" do
    user = users(:regular_user)
    get login_url
    old_session_id = session.id

    post login_url, params: { email: user.email, password: "password123" }
    assert_not_equal old_session_id, session.id
  end

  test "should destroy session" do
    user = users(:regular_user)
    post login_url, params: { email: user.email, password: "password123" }
    delete logout_url
    assert_redirected_to root_url
  end

  test "logout redirects with 303 see_other for Turbo" do
    user = users(:regular_user)
    post login_url, params: { email: user.email, password: "password123" }
    delete logout_url
    assert_response :see_other
    assert_redirected_to root_url
  end
end
