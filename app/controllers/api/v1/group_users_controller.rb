require Rails.root.join('app/controllers/application_controller.rb').to_s
module Api
  module V1
    class GroupUsersController < ApplicationController
      before_action :authenticate_user
      def invite
        # POST /api/v1/groups/invite
        # 渡されたemailを元にユーザーをグループに招待する。
        # args: group_id, email
        # return: message
        group = Group.find_by(id: params[:group_id])
        user = User.find_by(email: params[:email])

        if group.nil?
          render json: { message: 'グループが見つかりませんでした。' }, with: :unprocessable_entity
        elsif user.nil?
          render json: { message: 'ユーザーが見つかりませんでした。' }, with: :unprocessable_entity
        else
          group_user = GroupUser.create(group_id: group.id, user_id: user.id, status: :invited, role: :member)
          if group_user.save
            render json: { message: 'ユーザーを招待しました。' }
          else
            render json: { message: 'ユーザーを招待できませんでした。' }, with: :unprocessable_entity
          end
        end
      end

      def accept
        # POST /api/v1/groups/accept
        # ユーザーをグループに参加させる
        # args: group_id
        # return: message

        group = Group.find_by(id: params[:group_id])
        # ユーザーのグループステータスを変更する
        group_user = group.group_users.find_by(user_id: @current_user.id)
        group_user.status = 'joined'
        if group_user.save
          render json: { message: 'グループに参加しました。' }
        else
          render json: { message: 'グループに参加できませんでした。' }, with: :unprocessable_entity
        end
      end

      private

      def admin?
        # グループの管理者かどうかを確認する
        group = Group.find_by(id: params[:group_id])
        group_user = group.group_users.find_by(user_id: @current_user.id)
        return false unless group_user.role != 'admin'

        render json: { message: '管理者権限がありません。' }, with: :unprocessable_entity
      end
    end
  end
end
