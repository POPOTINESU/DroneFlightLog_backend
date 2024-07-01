class AddLastAccessed < ActiveRecord::Migration[7.1]
  def change
    add_column :group_users, :last_accessed, :datetime
  end
end
