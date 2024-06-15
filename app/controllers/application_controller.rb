class ApplicationController < ActionController::API
  before_action :authenticate_user

  private

  def authenticate_user
    user = authenticate(request)
    if user.is_a?(User)
      @currenr_user = user
    else
      render json: { error: user }, status: :unauthorized
    end
  end

  def authenticate(request)
    view_context.helper_method
    if request.headers['Authorization'].present?
      verify_access_token(request)
    else
      'Token not found'
    end
  end
end
