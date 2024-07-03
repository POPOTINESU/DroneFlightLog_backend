class FlightLogDrone < ApplicationRecord
  # Relationships
  belongs_to :flight_log
  belongs_to :drone
end
