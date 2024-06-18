class Group < ApplicationRecord
  # Relationships
  # A group has many users
  # A group has many flight_logs
  # A group has many drones

  has many :group_users
  has many :users, through: :group_users
  # has_many :flight_logs
  # has_many :drones

  # tabele_data
  # id: uuid
  # name: string

  validate :name, presence: true
end
