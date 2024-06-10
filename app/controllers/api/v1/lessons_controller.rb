class Api::V1::LessonsController < ApplicationController
  include Rails.application.routes.url_helpers
  skip_before_action :verify_authenticity_token
  before_action :set_lesson, only: %i[show update destroy]

  def index
    if params[:course_module_id]
      Rails.logger.info("Course Module ID: #{params[:course_module_id]}")
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
    Rails.logger.info("Received params: #{params.inspect}")
    lesson_params = lesson_params_with_conversions
    @lesson = Lesson.new(lesson_params)
    Rails.logger.info("Lesson attributes before save: #{@lesson.attributes.inspect}")

    begin
      if @lesson.save
        Rails.logger.info("Lesson saved successfully: #{@lesson.id}")
        if params[:lesson][:files].present?
          Rails.logger.info("Files present, attaching to lesson")
          files = params[:lesson][:files]
          attach_files_with_retries(@lesson, files)
        end
        Rails.logger.info("Final lesson data: #{lesson_with_files_json(@lesson)}")
        render_lesson_json(@lesson, :created)
      else
        Rails.logger.error("Lesson save errors: #{@lesson.errors.full_messages}")
        render json: { success: false, message: @lesson.errors.full_messages }, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error("Unexpected error: #{e.message}")
      render json: { success: false, message: "Unexpected error: #{e.message}" }, status: :internal_server_error
    end
  end

  def update
    lesson_params = lesson_params_with_conversions
    if @lesson.update(lesson_params)
      attach_files_with_retries(@lesson, params[:lesson][:files]) if params[:lesson][:files].present?
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

  def lesson_params_with_conversions
    lesson_params.tap do |lp|
      lp[:course_module_id] = lp[:course_module_id].to_i if lp[:course_module_id].present?
      lp[:google_form_links] = lp[:google_form_links].reject(&:blank?) if lp[:google_form_links].present?
    end
  end

  def lesson_params
    params.require(:lesson).permit(:course_module_id, :title, :description, google_form_links: [], files: [])
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
      files: lesson.files.map do |file|
        {
          url: url_for(file),
          filename: file.filename.to_s,
          content_type: file.content_type
        }
      end
    )
    lesson_attributes
  end

  def render_error_response(errors, status)
    render json: { success: false, message: errors }, status: status
  end

  def render_lesson_not_found
    render json: { success: false, message: 'Lesson not found' }, status: :not_found
  end

  def attach_files_with_retries(lesson, files, retries = 3)
    files.each do |file|
      next unless file.is_a?(ActionDispatch::Http::UploadedFile)

      begin
        Rails.logger.info("Attempting to attach file: #{file.original_filename}")
        lesson.files.attach(io: file.tempfile, filename: file.original_filename, content_type: file.content_type)
        Rails.logger.info("File attached successfully: #{file.original_filename}")
      rescue ActiveStorage::IntegrityError => e
        if (retries -= 1) > 0
          Rails.logger.warn("Integrity error detected, retrying... (#{retries} retries left)")
          retry
        else
          Rails.logger.error("Failed to attach file after multiple attempts: #{file.original_filename}")
          raise e
        end
      end
    end
  end
end
