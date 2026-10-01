require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  # Signup routes have been removed (PRD-0002: RubyConf.at Edition)
  # Users are now registered by admins only

  test "signup route does not exist" do
    get "/signup"
    assert_response :not_found
  end
end
