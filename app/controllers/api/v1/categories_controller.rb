class Api::V1::CategoriesController < ApplicationController
  before_action :set_api_category, only: %i[show update destroy]

  def index
    @api_categories = Category.all
    render_categories_json
  end

  def show
    render_category_json
  end

  def create
    @api_category = Category.new(category_params)
    if @api_category.save
      render_category_json(status: :created)
    else
      render json: { success: false, message: @api_category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @api_category.update(category_params)
      render_category_json
    else
      render json: { success: false, message: @api_category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @api_category.destroy
      render json: { success: true, message: 'Category deleted' }
    else
      render json: { success: false, message: @api_category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_api_category
    @api_category = Category.find_by(id: params[:id])
    render_category_not_found unless @api_category
  end

  def category_params
    params.require(:category).permit(:title, :image)
  end

  def render_categories_json
    if @api_categories.present?
      render json: { success: true, categories: @api_categories }
    else
      render json: { success: false, message: 'No categories found' }
    end
  rescue StandardError => e
    render json: { success: false, message: e.message }
  end

  def render_category_json(status: :ok)
    render json: { success: true, category: @api_category }, status:
  end

  def render_category_not_found
    render json: { success: false, message: 'Category not found' }, status: :not_found
  end
end
