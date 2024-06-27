class AddDrones < ActiveRecord::Migration[7.1]
  def change
    create_table :drones, id: :uuid do |t|
      t.string :drone_number, null: false
      t.string :JUNumber, null: false
      t.date :purchaseDate, null: false
    end
    add_index :drones, :drone_number, unique: true
    add_index :drones, :JUNumber, unique: true
  end
end

# TODO: purchseDateの追加
# TODO: このマイグレーションファイルを修正して、dronesテーブルにpurchaseDateを追加してください。
# TODO: purchaseDateは日付型で、nullを許可しないようにしてください。
