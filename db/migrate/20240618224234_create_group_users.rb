class CreateGroupUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :group_users do |t|
      t.references :group, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
