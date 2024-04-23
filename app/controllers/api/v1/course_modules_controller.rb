class Api::V1::CourseModulesController < ApplicationController
  before_action :set_course
  before_action :set_course_module, only: %i[show update destroy]

  def index
    @course_modules = @course.course_modules
    render_course_modules_json
  end

  def show
    render_course_module_json
  end

  def create
    @course_module = @course.course_modules.build(course_module_params)
    if @course_module.save
      render_course_module_json(status: :created)
    else
      render json: { success: false, message: @course_module.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @course_module.update(course_module_params)
      render_course_module_json
    else
      render json: { success: false, message: @course_module.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @course_module.destroy
      render json: { success: true, message: 'Module deleted' }
    else
      render json: { success: false, message: @course_module.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_course_module
    @course_module = @course.course_modules.find_by(id: params[:id])
    render_course_module_not_found unless @course_module
  end

  def course_module_params
    params.require(:course_module).permit(:week, :title, :description, :amount_of_lessons)
  end

  def render_course_modules_json
    if @course_modules.present?
      render json: { success: true, course_modules: @course_modules }
    else
      render json: { success: false, message: 'No modules found for this course' }
    end
  rescue StandardError => e
    render json: { success: false, message: e.message }
  end

  def render_course_module_json(status: :ok)
    render json: { success: true, course_module: @course_module }, status:
  end

  def render_course_module_not_found
    render json: { success: false, message: 'Module not found' }, status: :not_found
  end
end
