require Rails.root.join('app/controllers/application_controller.rb').to_s
module Api
  module V1
    class GroupsController < ApplicationController
      before_action :authenticate_user, only: %i[index]
      def index
        # GET /api/v1/groups
        user = User.find_by(id: @current_user.id)
        if user.nil?
          render json: { message: 'ユーザーが取得できませんでした。' }, with: :unprocessable_entity
        else
          groups = user.groups
          if groups.exists?
            render json: groups
          else
            render json: { message: 'グループを取得できませんでした。' }, with: :unprocessable_entity
          end
        end
      end
    end
  end
end
