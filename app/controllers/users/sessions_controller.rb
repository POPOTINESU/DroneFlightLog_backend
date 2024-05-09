# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: [:create]

  # before_action :configure_sign_in_params, only: [:create]

  def new
    render json: {message: 'ログインしてください。'}, status: :ok
  end

  # POST /resource/sign_in
  def create
    user = User.find_by(email: params[:email], password: params[:password])
    if user
      render json: {message: 'ログインに成功しました。'}, status: :ok
    else
      render json: {error: 'ログインに失敗しました。'}, status: :unauthorized
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
