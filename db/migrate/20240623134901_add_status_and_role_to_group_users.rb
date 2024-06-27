class AddStatusAndRoleToGroupUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :group_users, :status, :integer, default: 0
    add_column :group_users, :role, :integer, default: 0
  end
end
