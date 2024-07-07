class ApplicationController < ActionController::API
  include ActionController::Cookies

  private

  def authenticate_user
    user = verify_access_token(request)
    unless user.is_a?(User)
      return render json: { error: user }, status: :unauthorized
    end

    @current_user = user
  end

  def verify_access_token(request)
    access_token_secret = Rails.application.credentials.access_token_secret
    access_token = cookies.signed[:access_token]
    return 'Access token not found' unless access_token

    begin
      decoded_access_token = JWT.decode(access_token, access_token_secret, true, algorithm: 'HS256')
      user_id = decoded_access_token[0]['user_id']
      User.find(user_id)
    rescue JWT::DecodeError => e
      Rails.logger.info "Access token decode error: #{e.message}"
      verify_refresh_token(request)
    end
  end

  def verify_refresh_token(_request)
    refresh_token_secret = Rails.application.credentials.refresh_token_secret
    refresh_token = cookies.signed[:refresh_token]
    return 'Refresh token not found' unless refresh_token

    begin
      decoded_refresh_token = JWT.decode(refresh_token, refresh_token_secret, true, algorithm: 'HS256')
      user_id = decoded_refresh_token[0]['user_id']
      user = User.find(user_id)
      access_token(user)
      user
    rescue JWT::DecodeError => e
      Rails.logger.info "Refresh token decode error: #{e.message}"
      'ログインしてください'
    end
  end

  def access_token(user)
    access_token_secret = Rails.application.credentials.access_token_secret
    payload = { user_id: user.id }
    access_token = JWT.encode(payload, access_token_secret, 'HS256')
    cookies.signed[:access_token] = { value: access_token, httponly: true, secure: Rails.env.production?, expires: 1.hour.from_now }
  end
end
