class Drone < ApplicationRecord
  # Relationships
  # droneは複数のflightsを持つ
  # droneは複数のgroupsを持つ

  has_many :flights
  has_many :groups

  # Validations
  # drone_numberは必須で一意である
  # JUNumberは必須で一意である
  # purchaseDateは必須である
  # purchaseDateは過去の日付である
  # purchaseDateは未来の日付であってはならない
  # purchaseDateは日付である
  # purchaseDateはnullであってはならない


  validates :drone_number, presence: true, uniqueness: true
  validates :JUNumber, presence: true, uniqueness: true
  validates :purchaseDate, presence: true
  validate :purchase_date_cannot_be_in_the_future
  validate :purchase_date_cannot_be_null
  validate :purchase_date_must_be_a_date
end
