require Rails.root.join('app/controllers/application_controller.rb').to_s

module Api
  module V1
    class UsersController < ApplicationController
      # before_action :authenticate_user, only: %i[show]
    end
  end
end
