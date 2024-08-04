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

      def self.alert_inspection
        drones = Drone.where(inspection_date: ..1.week.from_now)
        drones.each do |drone|
          drone.groups.each do |group|
            group.users.each do |user|
              DroneMailer.with(user:, drone:).inspection_date.deliver_now
            end
          end
        end

        Rails.logger.info 'ドローンの定期点検が近づいています。'
      end

      private

      def group_params
        params.require(:group).permit(:name)
      end

      def add_drones_to_group(group)
        return if params[:droneSets].blank?

        params[:droneSets].each do |drone_set|
          drone = Drone.find_by(drone_number: drone_set[:droneNumber], JUNumber: drone_set[:JUNumber]) || Drone.create!(
            drone_number: drone_set[:droneNumber],
            JUNumber: drone_set[:JUNumber],
            purchase_date: drone_set[:purchaseDate],
            inspection_date: drone_set[:inspectionDate]
          )

          # ドローンが存在する場合は、グループに紐づいていない場合のみグループに追加する
          next if GroupDrone.exists?(group:, drone:)

          GroupDrone.create!(group:, drone:)
        end
      end
    end
  end
end
