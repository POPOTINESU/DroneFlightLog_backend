require Rails.root.join('app/controllers/application_controller.rb').to_s

module Api
  module V1
    class GroupsController < ApplicationController
      before_action :authenticate_user

      def index
        return if user_blank?

        group_users = GroupUser.where(user: @current_user, status: :joined).order(last_accessed: :desc)
        group_ids = group_users.pluck(:group_id)
        groups = Group.where(id: group_ids)
        if groups.empty?
          render json: { message: 'グループがありません。' }, status: :unprocessable_entity
        else
          drone_counts = GroupDrone.where(group_id: group_ids).group(:group_id).count
          render json: groups.map { |group|
            {
              id: group.id,
              name: group.name,
              user_count: group.users.count,
              drone_count: drone_counts[group.id] || 0
            }
          }
        end
      end

      def show
        group = Group.includes(:users, group_drones: :drone).find_by(id: params[:id])
        if group.nil?
          render json: { message: 'グループが見つかりませんでした。' }, status: :unprocessable_entity
        else
          group_user = GroupUser.find_by(user: @current_user, group:)
          render json: {
            id: group.id,
            name: group.name,
            users: group.users.map do |user|
                     { id: user.id, name: user.full_name, email: user.email, role: group_user.role, status: group_user.status }
                   end,
            drones: group.group_drones.map do |gd|
                      { id: gd.drone.id, drone_number: gd.drone.drone_number, JUNumber: gd.drone.JUNumber,
                        purchaseDate: gd.drone.purchaseDate }
                    end
          }
        end
      end

      def create
        return if user_blank?

        ActiveRecord::Base.transaction do
          group = Group.new(group_params)
          group_user = GroupUser.new(user: @current_user, group:, status: :joined, role: :admin)

          if group.save
            group_user.save!
            add_members_to_group(group)
            add_drones_to_group(group)
            render json: { message: 'グループを作成しました。' }, status: :created
          else
            Rails.logger.error "グループの作成に失敗しました: #{group.errors.full_messages.join(', ')}"
            render json: { message: 'グループを作成できませんでした。', errors: group.errors.full_messages }, status: :unprocessable_entity
          end
        rescue StandardError => e
          Rails.logger.error "保存処理中にエラーが発生しました: #{e.message}"
          render json: { message: "保存処理中にエラーが発生しました: #{e.message}" }, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
      end

      def invited_users
        # 　招待されていて、まだ参加していないユーザーを取得する
        #
        # Returns:
        # invited_users: 招待されているユーザー

        # ユーザーが紐づいているstatusがinvitedのグループを取得する

        group_users = GroupUser.where(user: @current_user, status: :invited)
        group_ids = group_users.pluck(:group_id)
        groups = Group.where(id: group_ids)
        invited_users = groups.map do |group|
          {
            id: group.id,
            name: group.name,
            user_count: group.users.count
          }
        end
        render json: invited_users
      end

      def participate_or_reject
        group = Group.find_by(id: params[:id])
        return render json: { message: 'グループが見つかりませんでした。' }, status: :unprocessable_entity if group.nil?

        if params[:is_accept]
          # グループに参加する処理
          group_user = GroupUser.find_or_initialize_by(user: @current_user, group:)
          group_user.status = :joined
          group_user.role = :member

          if group_user.save
            render json: { message: 'グループに参加しました。' }, status: :created
          else
            Rails.logger.error "グループへの参加に失敗しました: #{group_user.errors.full_messages.join(', ')}"
            render json: { message: 'グループに参加できませんでした。', errors: group_user.errors.full_messages }, status: :unprocessable_entity
          end
        else
          # グループの招待を拒否する処理
          group_user = GroupUser.find_by(user: @current_user, group:)

          if group_user&.destroy
            render json: { message: 'グループの招待を拒否しました' }, status: :ok
          else
            Rails.logger.error "グループからの招待を拒否できませんでした: #{group_user&.errors&.full_messages&.join(', ')}"
            render json: { message: 'グループからの招待を拒否できませんでした', errors: group_user&.errors&.full_messages },
                   status: :unprocessable_entity
          end
        end
      end

      private

      def user_blank?
        if @current_user.nil?
          render json: { message: 'ユーザーが取得できませんでした。' }, status: :unprocessable_entity
          return true
        end
        false
      end

      def group_params
        params.require(:group).permit(:name)
      end

      def add_members_to_group(group)
        return if params[:emails].blank?

        emails = JSON.parse(params[:emails])
        emails.each do |email|
          user = User.find_by(email:)
          if user
            group_user = GroupUser.new(user:, group:, status: :invited, role: :member)
            group_user.save!
          else
            Rails.logger.error "ユーザーが見つかりませんでした: #{email}"
          end
        end
      end

      def add_drones_to_group(group)
        return if params[:droneSets].blank?

        params[:droneSets].each do |drone_set|
          drone = Drone.create!(
            drone_number: drone_set[:droneNumber],
            JUNumber: drone_set[:JUNumber],
            purchaseDate: drone_set[:purchaseDate],
            inspectionDate: drone_set[:inspectionDate]
          ) do |d|
            d.purchaseDate = Date.parse(drone_set[:purchaseDate])
            d.inspectionDate = Date.parse(drone_set[:inspectionDate])
          end

          GroupDrone.create!(group:, drone:) unless GroupDrone.exists?(group:, drone:)
        end
      end
    end
  end
end
