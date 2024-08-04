class DroneMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  def alert_inspection_email(drone)
    @drone = drone
    mail(to: drone.group.users.pluck(:email), subject: 'Drone Inspection Alert')
  end
