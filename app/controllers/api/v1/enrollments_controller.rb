class Api::V1::EnrollmentsController < ApplicationController
  before_action :set_enrollment, only: [:show, :update, :destroy]

  # POST /api/v1/enrollments
  def create
    enrollment = Enrollment.new(enrollment_params)
    if enrollment.save
      render json: enrollment, status: :created
    else
      render json: enrollment.errors, status: :unprocessable_entity
    end
  end

  # GET /api/v1/enrollments/:id
  def show
    render json: @enrollment
  end

  # PATCH/PUT /api/v1/enrollments/:id
  def update
    if @enrollment.update(enrollment_params)
      render json: @enrollment
    else
      render json: @enrollment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/enrollments/:id
  def destroy
    @enrollment.destroy
    head :no_content
  end

  private

  def set_enrollment
    @enrollment = Enrollment.find(params[:id])
  end

  def enrollment_params
    params.require(:enrollment).permit(:user_id, :course_id)
  end
end
