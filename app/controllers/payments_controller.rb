class PaymentsController < ApplicationController
  def handle_success
    Rails.logger.debug("Received parameters: #{params.inspect}") # Log received parameters

    @course = Course.find_by(id: params[:course_id])
    unless @course
      render json: { error: 'Course not found' }, status: :not_found
      return
    end

    @api_user = User.find_by(id: params[:userId]) # Use @api_user instead of @user
    unless @api_user
      render json: { error: 'User not found' }, status: :not_found
      return
    end

    if @api_user.courses.exists?(@course.id) # Use @api_user instead of @user
      render json: { error: 'User has already paid for this course' }, status: :unprocessable_entity
      return
    end

    @api_user.courses << @course # Use @api_user instead of @user
    @course.course_modules.update_all(payment_status: CourseModule.payment_statuses[:paid])

    send_welcome_email(@api_user) # Use @api_user instead of @user

    render json: { message: 'Payment received successfully', course_modules: @course.course_modules }, status: :ok
  end

  private

  def send_welcome_email(user)
    password = user.password
    UserMailer.welcome_email(user, password).deliver_later
  end
end
