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
        drones = Drone.where(inspectDate: ..1.week.from_now)
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
          # ドローンが存在しない場合は新規作成
          # ドローンが存在する場合は、グループに紐づいていない場合のみ新規作成
          # ドローンが存在する場合で、グループに紐づいている場合はスキップ

          drone = Drone.find_by(drone_number: drone_set[:droneNumber])
          if drone.nil?
            drone = Drone.create!(drone_number: drone_set[:droneNumber], JUNumber: drone_set[:JUNumber],
                                  purchaseDate: drone_set[:purchaseDate])
          elsif drone&.groups&.exclude?(group)
            GroupDrone.create!(group:, drone:)
          end
          GroupDrone.create!(group:, drone:) unless GroupDrone.exists?(group:, drone:)
        end
      end
    end
  end
end
