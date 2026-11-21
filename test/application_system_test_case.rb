require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |driver_option|
    driver_option.add_argument("--no-sandbox")
    driver_option.add_argument("--disable-dev-shm-usage")
    driver_option.add_argument("--disable-gpu")
    # Chrome flags the fixture password as breached after a successful login; its
    # warning dialog then swallows the keystrokes of the next test's login form.
    driver_option.add_preference("profile.password_manager_leak_detection", false)
  end
end
