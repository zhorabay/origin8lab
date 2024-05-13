class ApplicationMailer < ActionMailer::Base
  default from: "info@origin8lab.com"
  layout "mailer"

  def self.default_url_options
    { host: 'origin8lab.com' }
  end
end
