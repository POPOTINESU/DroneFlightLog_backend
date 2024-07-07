module Api
  module V1
    class FlightLogsController < ApplicationController
      before_action :authenticate_user

      def index
        group = Group.find_by(id: params[:group_id])
        if group.nil?
          render json: { message: 'グループが見つかりませんでした。' }, status: :unprocessable_entity
        else
          flight_logs = FlightLog.joins(:flight_log_groups).where(flight_log_groups: { group_id: group.id }).includes(:drones, :users)
          flight_logs_with_details = flight_logs.map do |flight_log|
            {
              flight_log: flight_log,
              drones: flight_log.drones.select(:id, :JUNumber),
              users: flight_log.users.map { |user| { id: user.id, full_name: user.full_name } }
            }
          end
          render json: { flight_logs: flight_logs_with_details }, status: :ok
        end
      end

      def show
        flight_log = FlightLog.includes(:drones, :users).find_by(id: params[:id])
        if flight_log.nil?
          render json: { message: 'フライトログが見つかりませんでした。' }, status: :unprocessable_entity
        else
          render json: {
            flight_log: flight_log,
            drones: flight_log.drones.select(:id, :JUNumber),
            users: flight_log.users.map { |user| { id: user.id, full_name: user.full_name } },
            groups: flight_log.groups.map { |group| { id: group.id, name: group.name } }
          }, status: :ok
        end
      end

      def create
        ActiveRecord::Base.transaction do
          data = flight_log_params
          user = User.find_by(email: data[:pilot_name])
          drone = Drone.find_by(id: data[:JUNumber])
          group = Group.find_by(id: data[:group_id])

          if user.nil?
            render json: { error: 'ユーザーが見つかりませんでした。' }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end

          if drone.nil?
            render json: { error: 'ドローンが見つかりませんでした。' }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end

          if group.nil?
            render json: { error: 'グループが見つかりませんでした。' }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
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

          if flight_log.save
            create_flight_log(flight_log)
            render json: { message: 'フライトログを作成しました。' }, status: :created
          else
            render json: { error: flight_log.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end

      def edit
        flight_log = FlightLog.find_by(id: params[:id])
        if flight_log.nil?
          render json: { message: 'フライトログが見つかりませんでした。' }, status: :unprocessable_entity
        else
          render json: { flight_log: flight_log }, status: :ok
        end
      end

      def update
        ActiveRecord::Base.transaction do
          flight_log = FlightLog.find_by(id: params[:id])
          if flight_log.nil?
            render json: { message: 'フライトログが見つかりませんでした。' }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end

          data = flight_log_params
          user = User.find_by(id: data[:pilot_name])
          drone = Drone.find_by(id: data[:JUNumber])
          group = Group.find_by(id: data[:group_id])

          if user.nil?
            render json: { error: 'ユーザーが見つかりませんでした。' }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end

          if drone.nil?
            render json: { error: 'ドローンが見つかりませんでした。' }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end

          if group.nil?
            render json: { error: 'グループが見つかりませんでした。' }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end

          if flight_log.update(
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
            flight_log.drones.destroy_all
            flight_log.users.destroy_all
            flight_log.groups.destroy_all

            create_flight_log(flight_log)

            render json: { message: 'フライトログを更新しました。' }, status: :ok
          else
            Rails.logger.debug flight_log.errors.full_messages
            render json: { error: flight_log.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end

      def destroy
        ActiveRecord::Base.transaction do
          flight_log = FlightLog.find_by(id: params[:id])
          if flight_log.nil?
            render json: { message: 'フライトログが見つかりませんでした。' }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end

          # 先に関連するレコードを削除
          FlightLogUser.where(flight_log_id: flight_log.id).destroy_all
          FlightLogDrone.where(flight_log_id: flight_log.id).destroy_all
          FlightLogGroup.where(flight_log_id: flight_log.id).destroy_all

          if flight_log.destroy
            render json: { message: 'フライトログを削除しました。' }, status: :ok
          else
            render json: { error: flight_log.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end

      private

      def create_flight_log(flight_log)
        FlightLogUser.create!(flight_log_id: flight_log.id, user_id: user.id)
        FlightLogDrone.create!(flight_log_id: flight_log.id, drone_id: drone.id)
        FlightLogGroup.create!(flight_log_id: flight_log.id, group_id: group.id)
      end

      def flight_log_params
        params.require(:flight_log).permit(
          :flight_date, :pilot_name, :group_id, :JUNumber, :flight_summary,
          :takeoff_location, :landing_location, :takeoff_time,
          :landing_time, :total_time, :malfunction_content,
          flight_purpose: [], specific_flight_types: []
        )
      end
    end
  end
end
