require Rails.root.join('app/controllers/application_controller.rb').to_s
module Api
  module V1
    class GroupsController < ApplicationController
      before_action :authenticate_user, only: %i[index]
      def index
        # GET /api/v1/groups@current_user
        # args: access_token, refresh_token
        # return: id, name
        if @current_user.nil?
          render json: { message: 'ユーザーが取得できませんでした。' }, with: :unprocessable_entity
        else
          groups = @current_user.groups
          if groups.empty?
            render json: { message: 'グループがありません。' }, with: :unprocessable_entity
          else
            render json: groups.map { |group| { id: group.id, name: group.name, user_count: group.users.count } }
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
            render json: group
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
