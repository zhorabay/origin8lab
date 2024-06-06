class Api::V1::LessonsController < ApplicationController
  include Rails.application.routes.url_helpers
  skip_before_action :verify_authenticity_token
  before_action :set_lesson, only: %i[show update destroy]

  def index
    if params[:course_module_id]
      course_module = CourseModule.find_by(id: params[:course_module_id])
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
  
    if params[:lesson][:files].present?
      params[:lesson][:files].each do |file|
        @lesson.files.attach(file)
      end
    end
  
    if @lesson.save
      render_lesson_json(@lesson, :created)
    else
      render json: { success: false, message: @lesson.errors.full_messages }, status: :unprocessable_entity
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
    @lesson = Lesson.includes(:files_attachments).find_by(id: params[:id])
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
      files: lesson.files.map { |file| { url: url_for(file), filename: file.filename.to_s, content_type: file.content_type } }
    )

    lesson_attributes
  end  

  def render_error_response(errors, status)
    render json: { success: false, message: errors }, status: status
  end

  def render_lesson_not_found
    render json: { success: false, message: 'Lesson not found' }, status: :not_found
  end
end
