class PaymentsController < ApplicationController
  def handle_payment_success
    @api_user = current_user
    @api_course = Course.find(params[:course_id])

    @api_user.courses << @api_course

    UserMailer.welcome_email(@api_user).deliver_later

    render json: { message: 'Payment received successfully' }, status: :ok
  end
end
