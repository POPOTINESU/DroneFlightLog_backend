require Rails.root.join('app/controllers/application_controller.rb').to_s

module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user

      def index
        # ログインしているユーザーを返す
        # user_name: nameを返す
        render json: { user_name: @current_user.full_name }
      end
    end
  end
end
