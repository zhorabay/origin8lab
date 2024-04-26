class UserMailer < ApplicationMailer
  def welcome_email(api_user)
    @api_user = api_user
    mail(to: @api_user.email, subject: 'Welcome to Origin8lab!')
  end
end
