class GroupDrone < ApplicationRecord
  belongs_to :group
  belongs_to :drone

  validates :group_id, uniqueness: { scope: :drone_id }
  validates :group_id, presence: true
  validates :drone_id, presence: true
end
