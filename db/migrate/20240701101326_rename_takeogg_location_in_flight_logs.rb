class RenameTakeoggLocationInFlightLogs < ActiveRecord::Migration[7.1]
  def change
    rename_column :flight_logs, :takeogg_location, :takeoff_location
  end
end
