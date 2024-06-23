class Group < ApplicationRecord
  # Relationships
  # A group has many users
  # A group has many flight_logs
  # A group has many drones

  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users, dependent: :destroy
  # has_many :flight_logs
  # has_many :drones

  # tabele_data
  # id: uuid
  # name: string
  has_secure_password

  validates :name, presence: true
end
