class AddGroupIdAndPasswordToGroups < ActiveRecord::Migration[7.1]
  def change

    add_column :groups, :group_id, :string, null: false, default: ''
    add_index :groups, :group_id, unique: true

    add_column :groups, :password, :string, null: false, default:''
  end
end
