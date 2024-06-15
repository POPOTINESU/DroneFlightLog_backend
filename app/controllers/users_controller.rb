class UsersController < ApplicationController
  def create
    # POST /api/v1/users
    # args: email, password, password_confirmation
    # return: user
    # helper_method :access_token, :reflesh_token
    view_context.helper_method
    user = User.new(user_params)
    if user.save
      access_token(user)
      reflesh_token(user)
      render json: { user: }
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end
end
