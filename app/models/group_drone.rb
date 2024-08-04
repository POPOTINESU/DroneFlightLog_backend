class GroupDrone < ApplicationRecord
  belongs_to :group
  belongs_to :drone

  validates :group_id, uniqueness: { scope: :drone_id }
end
