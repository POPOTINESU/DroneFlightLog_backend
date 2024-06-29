require Rails.root.join('app/controllers/application_controller.rb').to_s
module Api
  module V1
    class DronesController < ApplicationController
      before_action :authenticate_user

      def create
        # POST /api/v1/drones
        # グループにドローンを追加する
        #
        # args: id, drone_set: [{droneNumber, JUNumber, droneName}]
        #
        # return: message
        ActiveRecord::Base.transaction do

          group = Group.find_by(id: params[:id])
          if group.nil?
            render json: { message: 'グループが見つかりませんでした。' }, status: :unprocessable_entity
          else
            add_drones_to_group(group)
            render json: { message: 'ドローンを追加しました。' }, status: :created
          end
        end
      end
      private
      def group_params
        params.require(:group).permit(:name)
      end

      def add_drones_to_group(group)
        return if params[:droneSets].blank?

        params[:droneSets].each do |drone_set|
          # ドローンが存在しない場合は新規作成
          # ドローンが存在する場合は、グループに紐づいていない場合のみ新規作成
          # ドローンが存在する場合で、グループに紐づいている場合はスキップ

          drone = Drone.find_by(drone_number: drone_set[:droneNumber])
          if drone.nil?
            drone = Drone.create!(drone_number: drone_set[:droneNumber], JUNumber: drone_set[:JUNumber], purchaseDate: drone_set[:purchaseDate])
          elsif drone && !drone.groups.include?(group)
            GroupDrone.create!(group: group, drone: drone)
          end
          unless GroupDrone.exists?(group: group, drone: drone)
            GroupDrone.create!(group: group, drone: drone)
          end
        end
      end
    end
  end
end
