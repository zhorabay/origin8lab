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

    @course.course_modules.each do |course_module|
      Rails.logger.debug("Course Module ID: #{course_module.id}, Payment Status: #{course_module.payment_status}")
      puts "Course Module ID: #{course_module.id}, Payment Status: #{course_module.payment_status}"
    end

    password = generate_random_password
    create_user_with_password(user_params, password)
    send_welcome_email(@user)

    render json: { message: 'Payment received successfully', course_modules: @course.course_modules }, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:name, :phone_number, :email, :whatsapp, :gender, :nationality, :birthdate, :surname, :userId)
  end

  # Method to generate a random password
  def generate_random_password
    SecureRandom.hex(8)
  end

  # Method to create a user with the provided parameters
  def create_user_with_password(user_params, password)
    User.create(user_params.merge(password: password))
  end

  # Method to send a welcome email to the user
  def send_welcome_email(user, password)
    UserMailer.welcome_email(user, password).deliver_later
  end
end
