require "#{Rails.root.join('app/controllers/application_controller.rb')}"

module Api
  module V1
    class AuthenticationsController < ApplicationController

      if Rails.env.production?
        rescue_from StandardError, with: :rescue_500
        rescue_from ActiveRecord::RecordNotFound, with: :rescue_404
        rescue_from ActionController::ParameterMissing, with: :rescue_400
        rescue_from ActiveRecord::RecordInvalid, with: :rescue_422
      end

      def login
        # POST /api/v1/authentications/login
        # args: email, password
        # return: user
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          @authenticated_user = user
          access_token(@authenticated_user)
          refresh_token(@authenticated_user)
          render json: { user: @authenticated_user.as_json(only: %i[id]) }
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      private

      def user_params
        params.permit(:email, :password)
      end

      def access_token(user)
        access_token_secret = Rails.application.credentials.access_token_secret
        payload = { user_id: user.id }
        access_token = JWT.encode(payload, access_token_secret, 'HS256')
        cookies.signed[:access_token] = { value: access_token, httponly: true, expires: 1.hour.from_now }
      end

      def refresh_token(user)
        refresh_token_secret = Rails.application.credentials.refresh_token_secret
        payload = { user_id: user.id }
        refresh_token = JWT.encode(payload, refresh_token_secret, 'HS256')
        cookies.signed[:refresh_token] = { value: refresh_token, httponly: true, expires: 2.weeks.from_now }
      end

      def delete_token
        cookies.delete(:access_token)
        cookies.delete(:refresh_token)
      end
    end
  end
end
