require Rails.root.join('app/controllers/application_controller.rb').to_s

module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user

      def login_user
        # ログインしているユーザーを返す
        # user_name: nameを返す
        render json: { user_name: @current_user.name }
      end
    end
  end
end
