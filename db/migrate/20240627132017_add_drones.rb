class AddDrones < ActiveRecord::Migration[7.1]
  def change
    create_table :drones, id: :uuid do |t|
      t.string :drone_number, null: false
      t.string :JUNumber, null: false
    end
    add_index :drones, :drone_number, unique: true
    add_index :drones, :JUNumber, unique: true
  end
end
