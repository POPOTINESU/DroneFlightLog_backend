require Rails.root.join('app/controllers/application_controller.rb').to_s

module Api
  module V1
    class GroupsController < ApplicationController
      before_action :authenticate_user

      def index
        if user_blank?
          return
        else
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
      end

      def create
        if user_blank?
          return
        else
          ActiveRecord::Base.transaction do
            group = Group.new(group_params)
            group_user = GroupUser.new(user: @current_user, group: group, status: :joined, role: :admin)

            if group.save
              group_user.save!
              add_members_to_group(group)
              add_drones_to_group(group)
              render json: { message: 'グループを作成しました。' }, status: :created
            else
              Rails.logger.error "グループの作成に失敗しました: #{group.errors.full_messages.join(', ')}"
              render json: { message: 'グループを作成できませんでした。', errors: group.errors.full_messages }, status: :unprocessable_entity
            end
          rescue => e
            Rails.logger.error "保存処理中にエラーが発生しました: #{e.message}"
            render json: { message: "保存処理中にエラーが発生しました: #{e.message}" }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        end
      end

      def show
        group = Group.includes(:users, group_drones: :drone).find_by(id: params[:id])
        if group.nil?
          render json: { message: 'グループが見つかりませんでした。' }, status: :unprocessable_entity
        else
          group_user = GroupUser.find_by(user: @current_user, group: group)
          render json: {
            id: group.id,
            name: group.name,
            users: group.users.map { |user| { id: user.id,name: user.full_name,  email: user.email, role: group_user.role, status: group_user.status } },
            drones: group.group_drones.map { |gd| { id: gd.drone.id, drone_number: gd.drone.drone_number, JUNumber: gd.drone.JUNumber, purchaseDate: gd.drone.purchaseDate } }
          }
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
          user = User.find_by(email: email)
          if user
            group_user = GroupUser.new(user: user, group: group, status: :invited, role: :member)
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
            purchaseDate: drone_set[:purchaseDate]
          ) do |d|
            d.purchaseDate = Date.parse(drone_set[:purchaseDate])
          end

          unless GroupDrone.exists?(group: group, drone: drone)
            GroupDrone.create!(group: group, drone: drone)
          end
        end
      end
    end
  end
end
