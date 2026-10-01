# Loads config/conference.yml into a global Conference config object.
#
# Usage anywhere in the app:
#   Conference.name         # => "RubyConf Austria 2026"
#   Conference.theme_color  # => "#e30818"
#
# Rebrand for your event by editing config/conference.yml — no code changes.

conference_config = Rails.application.config_for(:conference)["conference"] || {}

Conference = ActiveSupport::OrderedOptions.new.tap do |config|
  config.name          = conference_config.fetch("name", "My Conference")
  config.short_name    = conference_config.fetch("short_name", "Treasure Hunt")
  config.city          = conference_config.fetch("city", "your city")
  config.dates         = conference_config.fetch("dates", "")
  config.theme_color   = conference_config.fetch("theme_color", "#2563eb")
  config.logo_asset    = conference_config.fetch("logo_asset", nil)
  config.website_url   = conference_config.fetch("website_url", nil)
  config.contact_email = conference_config.fetch("contact_email", nil)
end
