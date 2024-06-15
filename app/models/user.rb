class User < ApplicationRecord
  # id: uuid
  # filst_name: string
  # last_name: string
  # email: string
  # password_digest: string

  has_secure_password

  # presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :password, presence: true
  # uniqueness: true
  validates :email, uniqueness: true

  # min_length:
  validates :password, length: { minimum: 6 }

  def full_name
    "#{last_name} #{first_name}"
  end
end
