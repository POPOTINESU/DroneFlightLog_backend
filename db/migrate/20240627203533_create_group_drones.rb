class CreateGroupDrones < ActiveRecord::Migration[7.1]
  def change
    create_table :group_drones do |t|
      t.references :group, null: false, foreign_key: true, type: :uuid
      t.references :drone, null: false, foreign_key: true, type: :uuid
      
      t.timestamps
    end
  end
end
