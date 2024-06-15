class UsersController < ApplicationController
  def create
    # POST /users
    # args: first_name,last_name,email, password
    # return: user, token
    @user = User.new(user_params)
    if @user.save
      token = encode_token(user_id: @user.id)
      render json: { user: @user, token: }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    # POST /login
    # args: email, password
    # return: user, token
    # return: error
    @user = User.find_by(email: params[:email])
    if @user&.authenticate(params[:password])
      token = encode_token(user_id: @user.id)
      render json: { user: @user, token: }, status: :ok
    else
      render json: { error: :failure }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end
end
