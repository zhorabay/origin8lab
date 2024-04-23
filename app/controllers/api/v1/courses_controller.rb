class Api::V1::CoursesController < ApplicationController
  before_action :set_api_course, only: %i[show update destroy]

  def index
    if params[:category_id]
      category = Category.find_by(id: params[:category_id])
      @api_courses = category ? category.courses : Course.all
    else
      @api_courses = Course.all
    end
    render_courses_json
  end

  def show
    render_course_json
  end

  def create
    @api_course = Course.new(course_params)
    if @api_course.save
      render_course_json(status: :created)
    else
      render json: { success: false, message: @api_course.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @api_course.update(course_params)
      render_course_json
    else
      render json: { success: false, message: @api_course.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @api_course.destroy
      render json: { success: true, message: 'Course deleted' }
    else
      render json: { success: false, message: @api_course.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_api_course
    @api_course = Course.find_by(id: params[:id])
    render_course_not_found unless @api_course
  end

  def course_params
    params.require(:course).permit(:title, :image, :description, :about, :duration, :price).merge(category_id:
    params[:category_id])
  end

  def render_courses_json
    if @api_courses.present?
      render json: { success: true, courses: @api_courses }
    else
      render json: { success: false, message: 'No courses found' }
    end
  end

  def render_course_json(status: :ok)
    render json: { success: true, course: @api_course }, status:
  end

  def render_course_not_found
    render json: { success: false, message: 'Course not found' }, status: :not_found
  end
end
