class CreateFlightLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :flight_logs, id: :uuid do |t|
      t.date :flight_date
      t.string :flight_summary
      t.string :takeogg_location
      t.string :landing_location
      t.time :takeoff_time
      t.time :landing_time
      t.time :total_time
      t.string :flight_purpose, array: true, default: []
      t.string :specific_flight_types, array: true, default: []

      t.timestamps
    end
  end
end
