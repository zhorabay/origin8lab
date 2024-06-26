class Api::V1::UsersController < ApplicationController
  before_action :set_api_user, only: %i[show update destroy]

  def index
    @api_users = User.all
    render_users_json
  end

  def show
    render_user_json
  end

  def create
    @api_user = User.new(api_user_params)

    if @api_user.save
      token = AuthenticationTokenService.encode(@api_user.id, ENV.fetch('HMAC_SECRET'))
      render json: { user: @api_user, token: token }, status: :created
    else
      Rails.logger.error(@api_user.errors.full_messages.join(', '))
      render json: { success: false, message: @api_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @api_user.update(api_user_params)
      render_user_json
    else
      render json: { success: false, message: @api_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @api_user.destroy
      render json: { success: true, message: 'User deleted' }
    else
      render json: { success: false, message: @api_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def courses
    user = User.find(params[:id])
    if user
      courses = user.courses
      render json: courses, status: :ok
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  private

  def set_api_user
    @api_user = User.find_by(id: params[:id])
    render_user_not_found unless @api_user
  end

  def api_user_params
    params.require(:user).permit(:name, :phone_number, :email, :whatsapp, :gender, :nationality, :birthdate, :surname, :userId, :password, :password_confirmation)
  end

  def render_users_json
    if @api_users.present?
      render json: { success: true, users: @api_users }
    else
      render json: { success: false, message: 'No users found' }
    end
  end

  def render_user_json(status: :ok)
    render json: { success: true, user: @api_user }, status: status
  end

  def render_user_not_found
    render json: { success: false, message: 'User not found' }, status: :not_found
  end
end
