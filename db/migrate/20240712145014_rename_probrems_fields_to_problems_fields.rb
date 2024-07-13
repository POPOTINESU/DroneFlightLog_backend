class RenameProbremsFieldsToProblemsFields < ActiveRecord::Migration[7.1]
  def change
    rename_table :probrems_fields, :problems_fields
  end
end
