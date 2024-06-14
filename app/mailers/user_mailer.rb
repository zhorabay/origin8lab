class UserMailer < ApplicationMailer
  def welcome_email(api_user, password)
    @api_user = api_user
    @password = password

    ses = Aws::SES::Client.new(
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_EMAIL_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_EMAIL_SECRET_ACCESS_KEY']
    )

    begin
      ses.send_email({
        destination: {
          to_addresses: [@api_user.email],
        },
        message: {
          body: {
            html: {
              charset: "UTF-8",
              data: render_to_string(template: 'user_mailer/welcome_email.html.erb', layout: false)
            },
            text: {
              charset: "UTF-8",
              data: render_to_string(template: 'user_mailer/welcome_email.text.erb', layout: false)
            }
          },
          subject: {
            charset: "UTF-8",
            data: "Welcome to Origin8lab!"
          }
        },
        source: "info@origin8lab.com"
      })
    rescue Aws::SES::Errors::ServiceError => e
      Rails.logger.error "Email failed to send: #{e.message}"
    end
  end
end
