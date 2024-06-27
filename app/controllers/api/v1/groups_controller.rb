require Rails.root.join('app/controllers/application_controller.rb').to_s
module Api
  module V1
    class GroupsController < ApplicationController
      before_action :authenticate_user
      def index
        # GET /api/v1/groups@current_user
        # args: access_token, refresh_token
        # return: id, name
        if user_blanck?
          return
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
        #
        # 招待されたユーザーはstatus: :invited, role: :member
        # args: with_cdentails
        # groupName:string, emails: Array, droneSets: Array

        # ユーザーが存在しない場合
        if user_blanck?
          return
        else
          group = Group.new(group_params)
          group_user = GroupUser.new(user: @current_user, group: group, status: :joined, role: :admin)
          if group.save && group_user.save
            render json: { message: 'グループを作成しました。' }
          else
            render json: { message: 'グループを作成できませんでした。' }, with: :unprocessable_entity
          end

          # メンバーを追加する
          if params[:emails].nil?
          else
            params[:emails].each do |email|
              user = User.find_by(email: email)
              if user.nil?
                render json: { message: 'ユーザーが見つかりませんでした。' }, with: :unprocessable_entity
              else
                group_user = GroupUser.new(user: user, group: group, status: :invited, role: :member)
                group_user.save
              end
            end
          end
        end
      end

      private

      def user_blanck?
        if @current_user.nil?
          render json: { message: 'ユーザーが取得できませんでした。' }, status: :unprocessable_entity
        end
      end

      def group_params
        params.permit(:groupName, emails: [], droneSets: [:droneNumber, :JUNumber, :purchaseDate])
      end

      def add_members_to_group(group)
        return if params[:emails].blank?

        # emailsをデコード
        emails = JSON.parse(params[:emails])

        emails.each do |email|
          user = User.find_by(email: email)
          if user
            group_user = GroupUser.new(user: user, group: group, status: :invited, role: :member)
            group_user.save!
          else
            # ユーザーが見つからない場合はスキップ
            Rails.logger.warn("User with email #{email} not found")
          end
        end
      end
    end
  end
end
