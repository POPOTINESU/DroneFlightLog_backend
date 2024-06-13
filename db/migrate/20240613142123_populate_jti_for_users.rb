class PopulateJtiForUsers < ActiveRecord::Migration[7.1]
  def up
    change_column_null :users, :jti, false
  end

  def down
    change_column_null :users, :jti, true
  end
end
