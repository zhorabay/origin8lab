class PaymentsController < ApplicationController
  def handle_success
    Rails.logger.debug("Received parameters: #{params.inspect}") # Log received parameters

    @course = Course.find_by(id: params[:course_id])
    unless @course
      render json: { error: 'Course not found' }, status: :not_found
      return
    end

    @api_user = User.find_by(id: params[:userId])
    unless @api_user
      render json: { error: 'User not found' }, status: :not_found
      return
    end

    if @api_user.courses.exists?(@course.id)
      render json: { error: 'User has already paid for this course' }, status: :unprocessable_entity
      return
    end

    @api_user.courses << @course
    @course.course_modules.update_all(payment_status: CourseModule.payment_statuses[:paid])
    @course.course_modules.each do |course_module|
      course_module.lessons.update_all(payment_status: Lesson.payment_statuses[:paid])
    end

    render json: { message: 'Payment received successfully', course_modules: @course.course_modules }, status: :ok
  end
end
