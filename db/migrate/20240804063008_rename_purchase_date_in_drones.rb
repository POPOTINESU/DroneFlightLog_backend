class RenamePurchaseDateInDrones < ActiveRecord::Migration[7.1]
  def change
    rename_column :drones, :purchaseDate, :purchase_date
  end
end
