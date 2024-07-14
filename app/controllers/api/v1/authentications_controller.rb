require Rails.root.join('app/controllers/application_controller.rb').to_s

module Api
  module V1
    class AuthenticationsController < ApplicationController
      if Rails.env.production?
        rescue_from StandardError, with: :rescue_five_hundred
        rescue_from ActiveRecord::RecordNotFound, with: :rescue_four_o_four
        rescue_from ActionController::ParameterMissing, with: :rescue_four_hundred
        rescue_from ActiveRecord::RecordInvalid, with: :rescue_four_twenty_two
      end

      def login
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          @authenticated_user = user
          access_token(@authenticated_user)
          refresh_token(@authenticated_user)
          render json: { user: @authenticated_user.as_json(only: %i[id]) }
        else
          render json: { error: 'パスワードまたは、メールアドレスが違います。' }, status: :unauthorized
        end
      end

      def logout
        # DELETE /api/v1/authentications/logout
        # JWTトークンを削除する
        # return: message
        cookies.delete(:access_token)
        cookies.delete(:refresh_token)
        render json: { message: 'ログアウトしました。' }
      end

      def signup
        # POST /api/v1/authentications/signup
        # 　ユーザーが登録できたら、JWTを使ってログイン状態にする
        # args: first_name, last_name, email, password
        # return: message
        @user = User.new(user_params)
        if @user.save
          access_token(@user)
          refresh_token(@user)
          render json: { message: 'ユーザー登録が完了しました。' }
        else
          render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:first_name, :last_name, :email, :password)
      end

      def access_token(user)
        access_token_secret = Rails.application.credentials.access_token_secret
        payload = { user_id: user.id }
        access_token = JWT.encode(payload, access_token_secret, 'HS256')
        cookies.signed[:access_token] = {
          value: access_token,
          httponly: true,
          expires: 1.hour.from_now,
          domain: Rails.env.production? ? '.drone-flight-log.com' : 'localhost',
          secure: Rails.env.production?,
          same_site: Rails.env.production? ? :lax : :lax
        }
      end
      
      def refresh_token(user)
        refresh_token_secret = Rails.application.credentials.refresh_token_secret
        payload = { user_id: user.id }
        refresh_token = JWT.encode(payload, refresh_token_secret, 'HS256')
        cookies.signed[:refresh_token] = {
          value: refresh_token,
          httponly: true,
          expires: 2.weeks.from_now,
          domain: Rails.env.production? ? '.drone-flight-log.com' : 'localhost',
          secure: Rails.env.production?,
          same_site: Rails.env.production? ? :lax : :lax
        }
      end
    end
  end
end
