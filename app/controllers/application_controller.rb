class ApplicationController < ActionController::API

  def authenticate(request)
    # リクエストヘッダーからアクセストークンを取得する
    # アクセストークンを検証して、有効であればユーザーを返す
    # 無効であれば、リフレッシュトークンを検証して、有効であれば新しいアクセストークンを発行してユーザーを返す
    # どちらも無効であれば、errrorを返す
    # ユーザーが存在しない場合もerrorを返す

    access_token = request.headers['Authorization']
    if access_token.present?
      begin
        access_token_secret = Rails.application.credentials.access_token_secret
        decoded_access_token = JWT.decode(access_token, access_token_secret, true, algorithm: 'HS256')
        user_id = decoded_access_token[0]['user_id']
        user = User.find(user_id)
        return user
      rescue JWT::DecodeError
        reflesh_token = request.headers['Reflesh']
        if reflesh_token.present?
          reflesh_token_secret = Rails.application.credentials.reflesh_token_secret
          decoded_reflesh_token = JWT.decode(reflesh_token, reflesh_token_secret, true, algorithm: 'HS256')
          user_id = decoded_reflesh_token[0]['user_id']
          user = User.find(user_id)
          access_token(user)
          return user
        end
          return user
        else
          return error 'ログインしてください'
        end
    end


  end

  def access_token(user)
    access_token_secret = Rails.application.credentials.access_token_secret
    payload = { user_id: user.id }
    JWT.encode(payload, access_token_secret, 'HS256')
    cookies.signed[:jwt] = { value: access_token, httponly: true, expires: 1.hour.from_now }
  end

  def reflesh_token(user)
    reflesh_token_secret = Rails.application.credentials.reflesh_token_secret
    payload = { user_id: user.id }
    JWT.encode(payload, reflesh_token_secret, 'HS256')
    cookies.signed[:jwt] = { value: reflesh_token,httponly: true, expires: 2.week.from_now }
  end
end
