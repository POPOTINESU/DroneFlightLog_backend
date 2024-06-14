class User < ApplicationRecord
  # id: uuid
  # filst_name: string
  # last_name: string
  # email: string
  # password_digest: string
  # created_at: datetime

  has_secure_password

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }
end
