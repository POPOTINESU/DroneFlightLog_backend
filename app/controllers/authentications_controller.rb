class AuthenticationsController < ApplicationController
  def create
    # POST /api/v1/authentications/login
    # args: email, password
    # return: user, token
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = encode_token(user_id: user.id)
      render json: { user:, token: }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
end
