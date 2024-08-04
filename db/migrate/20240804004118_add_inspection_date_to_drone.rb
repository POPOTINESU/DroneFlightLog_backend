class AddInspectionDateToDrone < ActiveRecord::Migration[7.1]
  def change
    add_column :drones, :inspection_date, :date, default: nil
  end
end
