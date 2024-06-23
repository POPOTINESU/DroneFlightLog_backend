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
        # args: name, group_id, password
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

      def login
        # POST /api/v1/authentications/login
        # 現在ログインしているユーザーとグループを紐づける
        # args: group_id, password
        # return: message

        group = Group.find_by(id: params[:group_id])
        if group.nil?
          render json: { message: 'グループIDまたは、パスワードが違います。' }, with: :unprocessable_entity
        else
          password = params[:password]
          if group.password == password
            @current_user.groups << group
            render json: { message: 'グループに参加しました。' }
          else
            render json: { message: 'グループIDまたは、パスワードが違います。' }, with: :unprocessable_entity
          end
        end
      end

      private

      def group_params
        params.permit(:name, :group_id, :password)
      end
    end
  end
end
