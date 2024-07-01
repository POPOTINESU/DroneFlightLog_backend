require Rails.root.join('app/controllers/application_controller.rb').to_s

module Api
  module V1
    class LocationsController < ApplicationController
      def current_location
        latitude = params[:latitude]
        longitude = params[:longitude]

        results = Geocoder.search([latitude, longitude])
        if results.any?
          render json: { address: results.first.address }
        else
          render json: { address: '現在位置が取得できません' }
        end
      end
    end
  end
end
