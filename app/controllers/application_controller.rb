class ApplicationController < ActionController::API
  include ActionController::Cookies

  private

  def rescue_five_hundred(exception)
    render json: { error: exception.message }, status: :internal_server_error
  end

  def rescue_four_o_four(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def rescue_four_hundred(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def rescue_four_twenty_two(exception)
    render json: { error: exception.message }, status: :unprocessable_content
  end

  def authenticate_user
    user = verify_access_token(request)
    return render json: { error: user }, status: :unauthorized unless user.is_a?(User)

    @current_user = user
    Rails.logger.info "Authenticated user: #{@current_user.id}"
  end

  def verify_access_token(request)
    access_token_secret = Rails.application.credentials.access_token_secret
    # Cookiesからアクセストークンを取得
    access_token = cookies.signed[:access_token]
    decoded_access_token = JWT.decode(access_token, access_token_secret, true, algorithm: 'HS256')
    user_id = decoded_access_token[0]['user_id']
    User.find(user_id)
  rescue JWT::DecodeError
    verify_refresh_token(request)
  end

  def verify_refresh_token(_request)
    refresh_token_secret = Rails.application.credentials.refresh_token_secret
    # Cookiesからリフレッシュトークンを取得
    refresh_token = cookies.signed[:refresh_token]
    decoded_refresh_token = JWT.decode(refresh_token, refresh_token_secret, true, algorithm: 'HS256')
    user_id = decoded_refresh_token[0]['user_id']
    user = User.find(user_id)
    access_token(user)
  rescue JWT::DecodeError
    'ログインしてください'
  end

  def access_token(user)
    access_token_secret = Rails.application.credentials.access_token_secret
    payload = { user_id: user.id }
    access_token = JWT.encode(payload, access_token_secret, 'HS256')
    cookies.signed[:access_token] = { value: access_token, httponly: true, expires: 1.hour.from_now }
  end
end
