class CreateProblemFields < ActiveRecord::Migration[7.1]
  def change
    create_table :problem_fields do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :flight_log, null: false, foreign_key: true, type: :uuid

      t.string :problem_description
      t.date :date_of_resolution_datetime
      t.string :corrective_action
      t.timestamps
    end
  end
end
