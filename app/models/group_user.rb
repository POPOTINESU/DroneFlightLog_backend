class GroupUser < ApplicationRecord
  belongs_to :group
  belongs_to :user

  # グループ招待の状態管理
  enum status: { invited: 0, joined: 10 }
  # 招待できるユーザーを管理
  enum role: { member: 0, admin: 10 }

  validates :role, presence: true

  # 最後にアクセスした日時を更新
  def touth_last_accessed
    update_attribute(:last_accessed, Time.current)
  end
end
