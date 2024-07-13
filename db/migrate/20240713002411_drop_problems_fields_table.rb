class DropProblemsFieldsTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :problems_fields do |t|
      t.uuid :user_id, null: false
      t.uuid :flight_log_id, null: false
      t.string :problem_description
      t.date :date_of_resolution_datetime
      t.string :corrective_action
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
