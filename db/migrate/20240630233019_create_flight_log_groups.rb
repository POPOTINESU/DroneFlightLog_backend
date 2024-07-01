class CreateFlightLogGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :flight_log_groups do |t|
      t.references :flight_log, null: false, foreign_key: true, type: :uuid
      t.references :group, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
