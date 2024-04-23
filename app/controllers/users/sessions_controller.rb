class Users::SessionsController < Devise::SessionsController
  # POST /login
  def create
    user = User.find_by(email: params[:user][:email])
    if user&.valid_password?(params[:user][:password])
      token = AuthenticationTokenService.encode(user.id, AuthenticationTokenService::HMAC_SECRET)
      render json: { user: user, token: token }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
end
