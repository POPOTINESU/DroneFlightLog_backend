module JwtTokenHelper
  def verify_access_token(request)
    begin
      access_token_secret = Rails.application.credentials.access_token_secret
      # Cookiesからアクセストークンを取得
      access_token = cookies.signed[:access_token]
      decoded_access_token = JWT.decode(access_token, access_token_secret, true, algorithm: 'HS256')
      user_id = decoded_access_token[0]['user_id']
      User.find(user_id)
    rescue JWT::DecodeError
      verify_reflesh_token(request)
    end
  end

  def verify_reflesh_token(request)
    begin
      reflesh_token_secret = Rails.application.credentials.reflesh_token_secret
      # Cookiesからリフレッシュトークンを取得
      reflesh_token = cookies.signed[:reflesh_token]
      decoded_reflesh_token = JWT.decode(reflesh_token, reflesh_token_secret, true, algorithm: 'HS256')
      user_id = decoded_reflesh_token[0]['user_id']
      user = User.find(user_id)
      access_token(user)
    rescue JWT::DecodeError
      return 'ログインしてください'
    end
  end

  def access_token(user)
    access_token_secret = Rails.application.credentials.access_token_secret
    payload = { user_id: user.id }
    JWT.encode(payload, access_token_secret, 'HS256')
    cookies.signed[:access_token] = { value: access_token, httponly: true, expires: 1.hour.from_now }
  end

  def reflesh_token(user)
    reflesh_token_secret = Rails.application.credentials.reflesh_token_secret
    payload = { user_id: user.id }
    JWT.encode(payload, reflesh_token_secret, 'HS256')
    cookies.signed[:reflesh_token] = { value: reflesh_token, httponly: true, expires: 2.weeks.from_now }
  end

  def delete_token
    cookies.delete(:access_token)
    cookies.delete(:reflesh_token)
  end
end
