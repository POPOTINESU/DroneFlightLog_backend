class FlightLog < ApplicationRecord
  # validate
  validates :flight_date, presence: true
  validates :takeoff_time, presence: true
  validates :landing_time, presence: true
  validates :takeoff_time, presence: true
  validates :landing_time, presence: true
  validates :total_time, presence: true
  validates :flight_purpose, presence: true
end
