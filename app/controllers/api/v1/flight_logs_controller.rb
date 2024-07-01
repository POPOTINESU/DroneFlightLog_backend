require Rails.root.join('app/controllers/application_controller.rb').to_s
module Api
  module V1
    class FlightLogsController < ApplicationController
      before_action :authenticate_user

      def index
        # GET /api/v1/flight_logs
        # グループに紐づくフライトログを取得する
        # args: id
        # return: flight_logs
        group = Group.find_by(id: params[:id])
        if group.nil?
          render json: { message: 'グループが見つかりませんでした。' }, status: :unprocessable_entity
        else
          flight_logs = group.flight_logs
          render json: { flight_logs: flight_logs }, status: :ok
        end
      end

      def create
        # POST /api/v1/flight_logs
        # フライトログを作成する
        # flight_log: {flight_date, pilot_name, ju_number, flight_summary, takeoff_location, landing_location, takeoff_time, landing_time, taotal_time, flight_purpose, specific_flight?types}
        # return: message
        ActiveRecord::Base.transaction do
          data = flight_log_params
          user = User.find_by(email: data[:pilot_name])
          drone = Drone.find_by(id: data[:ju_number])
          if user.nil?
            render json: { error: 'ユーザーが見つかりませんでした。' }, status: :unprocessable_entity
          end
          if drone.nil?
            render json: { error: 'ドローンが見つかりませんでした。' }, status: :unprocessable_entity
          end
          flight_log = FlightLog.new(
            flight_date: data[:flight_date],
            flight_summary: data[:flight_summary],
            takeoff_location: data[:takeoff_location],
            landing_location: data[:landing_location],
            takeoff_time: data[:takeoff_time],
            landing_time: data[:landing_time],
            total_time: data[:total_time],
            flight_purpose: data[:flight_purpose],
            specific_flight_types: data[:specific_flight_types]
          )
          if flight_log.save!
            FlightLogUser.create!(flight_log_id: flight_log.id, user_id: user.id)
            FlightLogDrone.create!(flight_log_id: flight_log.id, drone_id: drone.id)
            render json: { message: 'フライトログを作成しました。' }, status: :created
          else
            render json: { error: flight_log.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end

      private
      def flight_log_params
        params.require(:flight_log).permit(
          :flight_date, :pilot_name, :ju_number, :flight_summary,
          :takeoff_location, :landing_location, :takeoff_time,
          :landing_time, :total_time, :malfunction_content,
          flight_purpose: [], specific_flight_types: []
        )
      end
    end
  end
end
