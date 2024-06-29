require Rails.root.join('app/controllers/application_controller.rb').to_s

module Api
  module V1
    class GroupsController < ApplicationController
      before_action :authenticate_user

      def index
        if user_blank?
          return
        else
          groups = @current_user.groups
          if groups.empty?
            render json: { message: 'グループがありません。' }, status: :unprocessable_entity
          else
            drone_count = GroupDrone.where(group: groups).count
            render json: groups.map { |group| { id: group.id, name: group.name, user_count: group.users.count, drone_count: drone_count} }
          end
        end
      end

      def create
        if user_blank?
          return
        else
          ActiveRecord::Base.transaction do
            group = Group.new(group_params)
            Rails.logger.info "Group parameters: #{group_params.inspect}"
            Rails.logger.info "Group object: #{group.inspect}"
            group_user = GroupUser.new(user: @current_user, group: group, status: :joined, role: :admin)
            Rails.logger.info "GroupUser object: #{group_user.inspect}"

            if group.save
              Rails.logger.info "Group saved successfully: #{group.inspect}"
              group_user.save!
              Rails.logger.info "GroupUser saved successfully: #{group_user.inspect}"
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
