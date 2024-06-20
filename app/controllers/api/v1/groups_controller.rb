require Rails.root.join('app/controllers/application_controller.rb').to_s
module Api
  module V1
    class GroupsController < ApplicationController
      before_action :authenticate_user, only: %i[index]
      def index
        # GET /api/v1/groups
        user = User.find_by(id: @current_user)
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

      def create
        # POST /api/v1/groups
        user = User.find_by(id: @current_user.id)
        if user.nil?
          render json: { message: 'ユーザーが取得できませんでした。' }, with: :unprocessable_entity
        else
          group = user.groups.build(group_params)
          if group.save
            return render json: group
          else
            render json: { error: group.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end

      private

      def group_params
        params.permit(:name)
      end
    end
  end
end
