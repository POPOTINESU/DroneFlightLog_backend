class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: {message: "名前を入力してください"}
  validates :email, presence: {message: "メールアドレスを入力してください"}
  validates :password, presence: {message: "パスワードを入力してください"}

  validates :email, uniqueness: {message: "このメールアドレスは既に登録されています"}
end
