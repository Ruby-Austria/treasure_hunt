require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "logged in user is redirected to dashboard" do
    post login_url, params: { email: users(:regular_user).email, password: "password123" }
    get root_url
    assert_redirected_to dashboard_url
  end

  test "shows approved hunts on landing page" do
    hunt = hunts(:two)
    hunt.update!(status: :approved)

    get root_url
    assert_response :success
    assert_match hunt.name, response.body
  end
end
