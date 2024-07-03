class FlightLogUser < ApplicationRecord
  # Relationships
  belongs_to :flight_log
  belongs_to :user
end
