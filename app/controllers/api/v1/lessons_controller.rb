require 'aws-sdk-s3'

class Api::V1::LessonsController < ApplicationController
  include Rails.application.routes.url_helpers
  skip_before_action :verify_authenticity_token
  before_action :set_lesson, only: %i[show update destroy]

  def index
    if params[:course_module_id]
      course_module = CourseModule.find_by(id: params[:course_module_id].to_i)
      @lessons = course_module ? course_module.lessons : Lesson.all
    else
      @lessons = Lesson.all
    end
    render_lessons_with_files(@lessons)
  end

  def show
    render_lesson_with_files(@lesson)
  end

  def create
    @lesson = Lesson.new(lesson_params)
    Rails.logger.info("Lesson params: #{lesson_params.inspect}")
    Rails.logger.info("Lesson attributes before save: #{@lesson.attributes}")
  
    begin
      if @lesson.save
        Rails.logger.info("Lesson saved successfully")
        if params[:lesson][:files].present?
          Rails.logger.info("Files present, initiating upload")
          files = params[:lesson][:files]
          files.each do |file|
            begin
              upload_file_to_s3(file)
              @lesson.files.attach(io: file.tempfile, filename: file.original_filename, content_type: file.content_type)
            rescue => e
              Rails.logger.error("File upload error: #{e.message}")
              render json: { success: false, message: "File upload error: #{e.message}" }, status: :unprocessable_entity
              return
            end
          end
        end
        render_lesson_json(@lesson, :created)
      else
        Rails.logger.error("Lesson save errors: #{lesson_params.errors.full_messages}")
        render json: { success: false, message: @lesson.errors.full_messages }, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error("Unexpected error: #{e.message}")
      render json: { success: false, message: "Unexpected error: #{e.message}" }, status: :internal_server_error
    end
  end

  def update
    if @lesson.update(lesson_params)
      @lesson.files.attach(params[:lesson][:files]) if params[:lesson][:files].present?
      render_lesson_json(@lesson)
    else
      render_error_response(@lesson.errors.full_messages, :unprocessable_entity)
    end
  end

  def destroy
    if @lesson.destroy
      render json: { success: true, message: 'Lesson deleted' }
    else
      render_error_response(@lesson.errors.full_messages, :unprocessable_entity)
    end
  end

  private

  def set_lesson
    @lesson = Lesson.includes(:files_attachments).find_by(id: params[:id].to_i)
    render_lesson_not_found unless @lesson
  end

  def lesson_params
    params.require(:lesson).permit(:course_module_id, :title, :description, files: [])
  end

  def render_lessons_with_files(lessons)
    if lessons.present?
      render json: { success: true, lessons: lessons.map { |lesson| lesson_with_files_json(lesson) } }
    else
      render json: { success: false, message: 'No lessons found' }
    end
  end

  def render_lesson_with_files(lesson)
    if lesson.present?
      render json: { success: true, lesson: lesson_with_files_json(lesson) }
    else
      render_lesson_not_found
    end
  end

  def render_lesson_json(lesson, status = :ok)
    render json: { success: true, lesson: lesson_with_files_json(lesson) }, status: status
  end

  def lesson_with_files_json(lesson)
    return {} unless lesson.present?

    lesson_attributes = lesson.as_json
    lesson_attributes.merge!(
      files: lesson.files.map { |file| { url: url_for(file), filename: file.filename, content_type: file.content_type } }
    )
    lesson_attributes
  end

  def render_error_response(errors, status)
    render json: { success: false, message: errors }, status: status
  end

  def render_lesson_not_found
    render json: { success: false, message: 'Lesson not found' }, status: :not_found
  end

  def upload_file_to_s3(file)
    s3_client = Aws::S3::Client.new(
      region: ENV['AWS_REGION'],
      credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    )

    key = "#{Time.now.strftime('%Y%m%d%H%M%S')}"
  
    multipart_uploader = Aws::S3::MultipartFileUploader.new(
      client: s3_client,
      bucket: ENV['AWS_BUCKET'],
      key: key,
      multipart_threshold: 15.megabytes,
      max_concurrent_uploads: 5
    )

    Rails.logger.info("Uploading file #{file.original_filename} to S3 with key #{key}")
    multipart_uploader.upload(file.tempfile)
    Rails.logger.info("File #{file.original_filename} uploaded successfully to S3 with key #{key}")
  end
end
