require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  # /home now redirects to root (PRD-0002: RubyConf.at Edition)
  # All hunt listing functionality moved to PagesController

  test "home redirects to root" do
    post login_url, params: { email: users(:regular_user).email, password: "password123" }
    get home_url
    assert_redirected_to root_url
  end

  test "unauthenticated home redirects to root" do
    get home_url
    assert_redirected_to root_url
  end
end
