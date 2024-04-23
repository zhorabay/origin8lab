class Api::V1::CartsController < ApplicationController
  before_action :set_cart, only: [:destroy]

  def create
    @cart = current_user.carts.build(cart_params)
    if @cart.save
      render json: { success: true, message: 'Course added to cart successfully' }, status: :created
    else
      render json: { success: false, errors: @cart.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @cart.destroy
      render json: { success: true, message: 'Course removed from cart successfully' }, status: :ok
    else
      render json: { success: false, errors: @cart.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_cart
    @cart = current_user.carts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, message: 'Cart not found' }, status: :not_found
  end

  def cart_params
    params.require(:cart).permit(:course_id)
  end
end
