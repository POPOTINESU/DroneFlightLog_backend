require Rails.root.join('app/controllers/application_controller.rb').to_s

module Api
  module V1
    class GroupsController < ApplicationController
      before_action :authenticate_user

      def index
        return if user_blank?

        groups = @current_user.groups.includes(:users, :drones)
        if groups.empty?
          render json: { message: 'グループがありません。' }, status: :unprocessable_entity
        else
          render json: groups.map { |group| group_as_json(group) }
        end
      end

      def create
        return if user_blank?

        ActiveRecord::Base.transaction do
          group = Group.new(group_params)
          group_user = GroupUser.new(user: @current_user, group: group, status: :joined, role: :admin)

          if group.save
            group_user.save!
            add_members_to_group(group)
            add_drones_to_group(group)
            render json: { message: 'グループを作成しました。' }, status: :created
          else
            render json: { message: 'グループを作成できませんでした。' }, status: :unprocessable_entity
          end
        rescue => e
          Rails.logger.error "保存処理中にエラーが発生しました: #{e.message}"
          render json: { message: "保存処理中にエラーが発生しました: #{e.message}" }, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
      end

      def show
        group = Group.includes(:users, :drones).find_by(id: params[:id])
        if group.nil?
          render json: { message: 'グループが見つかりませんでした。' }, status: :unprocessable_entity
        else
          render json: group_as_json(group)
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
            Rails.logger.warn("User with email #{email} not found")
          end
        end
      end

      def add_drones_to_group(group)
        return if params[:droneSets].blank?

        params[:droneSets].each do |drone_set|
          drone = Drone.create!(
            drone_number: drone_set[:droneNumber],
            JUNumber: drone_set[:JUNumber],
            purchaseDate: Date.parse(drone_set[:purchaseDate])
          )

          unless GroupDrone.exists?(group: group, drone: drone)
            GroupDrone.create!(group: group, drone: drone)
          end
        end
      end

      def group_as_json(group)
        {
          id: group.id,
          name: group.name,
          user_count: group.users.count,
          drone_count: group.drones.count,
          users: group.users.map { |user| user_as_json(user, group) },
          drones: group.drones.map { |drone| drone_as_json(drone) }
        }
      end

      def user_as_json(user, group)
        {
          id: user.id,
          email: user.email,
          role: GroupUser.find_by(user: user, group: group).role
        }
      end

      def drone_as_json(drone)
        {
          id: drone.id,
          drone_number: drone.drone_number,
          JUNumber: drone.JUNumber,
          purchaseDate: drone.purchaseDate
        }
      end
    end
  end
end
