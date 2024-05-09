class RemoveTotalFlightTimeFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :total_flight_time, :integer
  end
end
