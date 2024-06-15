require "#{Rails.root}/app/controllers/application_controller.rb"

module Api
  module V1
    class UsersController < ApplicationController
      # before_action :authenticate_user, only: %i[show]
      def create
        # POST /api/v1/users
        # args: email, password, password_confirmation
        # return: user
        # helper_method :access_token, :reflesh_token
        user = User.new(user_params)
        if user.save
          render json: { user: }
        else
          render json: { error: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:email, :password, :password_confirmation)
      end
    end
  end
end
