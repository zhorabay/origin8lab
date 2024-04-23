class Api::V1::ReviewsController < ApplicationController
  before_action :set_api_course, only: %i[new create]
  before_action :set_api_review, only: :destroy

  def index
    @api_reviews = Review.all
    render_reviews_json
  end

  def new
    @api_user = current_api_user
    @api_review = Review.new
  end

  def create
    @api_user = current_api_user
    @api_review = @api_course.reviews.build(review_params.merge(user: @api_user))

    if @api_review.save
      redirect_to course_path(@api_course), notice: 'Review added successfully!'
    else
      render :new
    end
  end

  def destroy
    @api_review.destroy
    redirect_to course_path(@api_review.course), notice: 'Review deleted successfully!'
  end

  private

  def set_api_course
    @api_course = Course.find(params[:course_id])
  end

  def set_api_review
    @api_review = Review.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end

  def render_reviews_json
    if @api_reviews.present?
      render json: { success: true, reviews: @api_reviews }
    else
      render json: { success: false, message: 'No reviews found' }
    end
  rescue StandardError => e
    render json: { success: false, message: e.message }
  end
end
