class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      render json: { user: user }, status: :created
    else
      render json: { error: :failure }, status: :unauthorized
    end
  end
end
