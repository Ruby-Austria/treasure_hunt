require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:regular_user)
  end

  # Validations

  test "valid user" do
    user = User.new(email: "new@example.com", password: "password123")
    assert user.valid?
  end

  test "email is required" do
    user = User.new(email: nil, password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "email must be unique" do
    user = User.new(email: @user.email, password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "email uniqueness is case insensitive" do
    user = User.new(email: @user.email.upcase, password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "email must be valid format" do
    invalid_emails = [ "not-an-email", "missing@", "@missing.com", "spaces in@email.com" ]
    invalid_emails.each do |email|
      user = User.new(email: email, password: "password123")
      assert_not user.valid?, "#{email} should be invalid"
    end
  end

  test "valid email formats accepted" do
    valid_emails = [ "user@example.com", "user+tag@example.com", "user.name@example.co.uk" ]
    valid_emails.each do |email|
      user = User.new(email: email, password: "password123")
      assert user.valid?, "#{email} should be valid"
    end
  end

  test "password is required" do
    user = User.new(email: "new@example.com", password: "")
    assert_not user.valid?
  end

  test "password must be at least 6 characters" do
    user = User.new(email: "short@example.com", password: "abc")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 6 characters)"
  end

  test "password of exactly 6 characters is accepted" do
    user = User.new(email: "exact6@example.com", password: "abcdef")
    assert user.valid?
  end

  # has_secure_password

  test "authenticates with correct password" do
    assert @user.authenticate("password123")
  end

  test "rejects incorrect password" do
    assert_not @user.authenticate("wrong_password")
  end

  test "password is hashed" do
    user = User.new(email: "hash@example.com", password: "mypassword")
    assert_not_equal "mypassword", user.password_digest
    assert user.password_digest.start_with?("$2a$")
  end

  # Associations

  test "has many adventures" do
    assert_respond_to @user, :adventures
  end

  test "has many hunts through adventures" do
    assert_respond_to @user, :hunts
  end

  test "destroying user destroys adventures" do
    adventure_count = @user.adventures.count
    assert adventure_count > 0, "user should have at least one adventure"

    assert_difference("Adventure.count", -adventure_count) do
      @user.destroy
    end
  end

  # Admin

  test "admin attribute defaults to false" do
    user = User.create!(email: "nonadmin@example.com", password: "password123")
    assert_not user.admin?
  end

  test "admin user fixture is admin" do
    admin = users(:admin_user)
    assert admin.admin?
  end

  test "regular user fixture is not admin" do
    assert_not @user.admin?
  end
end
