class User < ApplicationRecord
  # tabele_data
  # id: uuid
  # filst_name: string
  # last_name: string
  # email: string
  # password_digest: string

  # Relationships

  has_many :group_users, dependent: :destroy
  has_many :groups, through: :group_users, dependent: :destroy

  has_many :flight_log_users, dependent: :destroy

  has_many :problem_fields, dependent: :destroy
  has_many :flight_logs, through: :problem_fields, dependent: :destroy

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

  def generate_reset_password_token!
    self.reset_password_token = SecureRandom.urlsafe_base64
    self.reset_password_sent_at = Time.current
    save(validate: false)
  end

  def clear_reset_password_token!
    self.reset_password_token = nil
    self.reset_password_sent_at = nil
    save(validate: false)
  end

  def password_token_valid?
    (reset_password_sent_at + 2.hours) > Time.current
  end
end
