class FlightLog < ApplicationRecord
  # Relationships
  has_many :flight_log_drones
  has_many :drones, through: :flight_log_drones
  has_many :flight_log_users
  has_many :flight_log_groups
  has_many :groups, through: :flight_log_groups
  has_many :problem_fields
  has_many :users, through: :problem_fields

  # validate
  validates :flight_date, presence: true
  validates :takeoff_time, presence: true
  validates :landing_time, presence: true
  validates :takeoff_time, presence: true
  validates :landing_time, presence: true
  validates :total_time, presence: true
  validates :flight_purpose, presence: true
end
