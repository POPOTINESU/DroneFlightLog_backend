require Rails.root.join('app/controllers/application_controller.rb').to_s
module Api
  module V1
    class GroupsController < ApplicationController
      before_action :authenticate_request
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
        # グループを作成したユーザーを管理者にする。
        # status: :joined, role: :admin
        # args: name
        user = User.find_by(id: @current_user.id)
        group = user.groups.create(group_params, status: :joined, role: :admin)
        if group.save
          render json: { message: 'グループを作成しました。' }
        else
          render json: { message: 'グループを作成できませんでした。' }, with: :unprocessable_entity
        end
      end

      private

      def group_params
        params.permit(:name)
      end
    end
  end
end
