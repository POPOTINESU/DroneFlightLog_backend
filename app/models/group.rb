class Group < ApplicationRecord
  # Relationships
  # A group has many users
  # A group has many flight_logs
  # A group has many drones

  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users, dependent: :destroy
  # has_many :flight_logs
  has_many :group_drones, dependent: :destroy
  has_many :drones, dependent: :destroy


  # tabele_data
  # id: uuid
  # name: string

  validates :name, presence: true
  validates :name, uniqueness: true
end
