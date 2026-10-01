class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "treasure-hunt@example.com")
  layout "mailer"
end
