# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_06_30_003141) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "drones", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "drone_number", null: false
    t.string "JUNumber", null: false
    t.date "purchaseDate", null: false
    t.index ["JUNumber"], name: "index_drones_on_JUNumber", unique: true
    t.index ["drone_number"], name: "index_drones_on_drone_number", unique: true
  end

  create_table "group_drones", force: :cascade do |t|
    t.uuid "group_id", null: false
    t.uuid "drone_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["drone_id"], name: "index_group_drones_on_drone_id"
    t.index ["group_id"], name: "index_group_drones_on_group_id"
  end

  create_table "group_users", force: :cascade do |t|
    t.uuid "group_id", null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.integer "role", default: 0
    t.datetime "last_accessed"
    t.index ["group_id"], name: "index_group_users_on_group_id"
    t.index ["user_id"], name: "index_group_users_on_user_id"
  end

  create_table "groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "group_drones", "drones"
  add_foreign_key "group_drones", "groups"
  add_foreign_key "group_users", "groups"
  add_foreign_key "group_users", "users"
end
