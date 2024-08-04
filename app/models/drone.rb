class Drone < ApplicationRecord
  # Relationships
  has_many :group_drones, dependent: :destroy
  has_many :groups, through: :group_drones, dependent: :destroy

  has_many :flight_log_drones, dependent: :destroy
  has_many :flight_logs, through: :flight_log_drones, dependent: :destroy

  # Validations
  validates :drone_number, presence: true
  validates :JUNumber, presence: true
  validates :purchase_date, presence: true
  validate :purchase_date_cannot_be_in_the_future
  validates :inspection_date, presence: true

  private

  def purchase_date_cannot_be_in_the_future
    return unless purchase_date.present? && purchase_date > Time.zone.today

    errors.add(:purchase_date, 'cannot be in the future')
  end
end
