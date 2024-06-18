class ApplicationController < ActionController::API
  include ActionController::Cookies

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
    if request.headers['Authorization'].present?
      verify_access_token(request)
    else
      render json: { error: 'ログインしてください' }, status: :unauthorized
    end
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
end
