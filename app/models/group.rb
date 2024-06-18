class Group < ApplicationRecord
  # Relationships
  # A group has many users
  # A group has many flight_logs
  # A group has many drones

  has_many :users
  # has_many :flight_logs
  # has_many :drones


  # tabele_data
  # id: uuid
  # name: string
  # FK: user_id
  # FK: flight_log_id
  # FK: drone_id

  validate :name, presence: true


end
