class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Userモデル
  # first_name: 名
  # last_name: 姓
  # email: メールアドレス
  # password: パスワード

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :first_name, presence: { message: "名を入力してください" }
  validates :last_name, presence: { message: "姓を入力してください" }
  validates :email, presence: { message: "メールアドレスを入力してください" }
  validates :password, presence: { message: "パスワードを入力してください" }

  validates :email, uniqueness: { message: "このメールアドレスは既に登録されています" }
end
