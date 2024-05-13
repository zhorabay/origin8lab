class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }
  before_action :set_mailer_default_url_options

  private

  def set_mailer_default_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
end
