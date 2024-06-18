class User < ApplicationRecord
  # tabele_data
  # id: uuid
  # filst_name: string
  # last_name: string
  # email: string
  # password_digest: string

  # Relationships

  has_many :group_users
  has_many :groups, through: :group_users

  has_secure_password

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :password, presence: true

  validates :email, uniqueness: true

  validates :password, length: { minimum: 6 }

  def full_name
    "#{last_name} #{first_name}"
  end
end
