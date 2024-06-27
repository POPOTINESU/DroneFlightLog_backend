class Drone < ApplicationRecord
  # Relationships
  has_many :group_drones
  has_many :groups, through: :group_drones

  # Validations
  validates :drone_number, presence: true, uniqueness: true
  validates :JUNumber, presence: true, uniqueness: true
  validates :purchaseDate, presence: true
  validate :purchase_date_cannot_be_in_the_future

  private

  def purchase_date_cannot_be_in_the_future
    if purchaseDate.present? && purchaseDate > Date.today
      errors.add(:purchaseDate, "cannot be in the future")
    end
  end
end