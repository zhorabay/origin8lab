class PaymentsController < ApplicationController
  def handle_success
    Rails.logger.debug("Received parameters: #{params.inspect}") # Log received parameters

    @course = Course.find_by(id: params[:course_id])
    unless @course
      render json: { error: 'Course not found' }, status: :not_found
      return
    end

    @user = User.find_by(id: params[:userId])
    unless @user
      render json: { error: 'User not found' }, status: :not_found
      return
    end

    if @user.courses.exists?(@course.id)
      render json: { error: 'User has already paid for this course' }, status: :unprocessable_entity
      return
    end

    @user.courses << @course

    @course.course_modules.update_all(payment_status: CourseModule.payment_statuses[:paid])

    UserMailer.welcome_email(@user).deliver_later

    render json: { message: 'Payment received successfully' }, status: :ok
  end
end
