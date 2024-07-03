class FlightLogGroup < ApplicationRecord
  # Relationships
  belongs_to :flight_log
  belongs_to :group
end
