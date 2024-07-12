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

ActiveRecord::Schema[7.1].define(version: 2024_07_12_145014) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "drones", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "drone_number", null: false
    t.string "JUNumber", null: false
    t.date "purchaseDate", null: false
    t.index ["JUNumber"], name: "index_drones_on_JUNumber", unique: true
    t.index ["drone_number"], name: "index_drones_on_drone_number", unique: true
  end

  create_table "flight_log_drones", force: :cascade do |t|
    t.uuid "flight_log_id", null: false
    t.uuid "drone_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["drone_id"], name: "index_flight_log_drones_on_drone_id"
    t.index ["flight_log_id"], name: "index_flight_log_drones_on_flight_log_id"
  end

  create_table "flight_log_groups", force: :cascade do |t|
    t.uuid "flight_log_id", null: false
    t.uuid "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_log_id"], name: "index_flight_log_groups_on_flight_log_id"
    t.index ["group_id"], name: "index_flight_log_groups_on_group_id"
  end

  create_table "flight_log_users", force: :cascade do |t|
    t.uuid "flight_log_id", null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_log_id"], name: "index_flight_log_users_on_flight_log_id"
    t.index ["user_id"], name: "index_flight_log_users_on_user_id"
  end

  create_table "flight_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "flight_date"
    t.string "flight_summary"
    t.string "takeoff_location"
    t.string "landing_location"
    t.time "takeoff_time"
    t.time "landing_time"
    t.time "total_time"
    t.string "flight_purpose", default: [], array: true
    t.string "specific_flight_types", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "problem_fields", force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "flight_log_id", null: false
    t.string "problem_description"
    t.date "date_of_resolution_datetime"
    t.string "corrective_action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_log_id"], name: "index_problem_fields_on_flight_log_id"
    t.index ["user_id"], name: "index_problem_fields_on_user_id"
  end

  create_table "problems_fields", force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "flight_log_id", null: false
    t.string "problem_description"
    t.date "date_of_resolution_datetime"
    t.string "corrective_action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_log_id"], name: "index_problems_fields_on_flight_log_id"
    t.index ["user_id"], name: "index_problems_fields_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "flight_log_drones", "drones"
  add_foreign_key "flight_log_drones", "flight_logs"
  add_foreign_key "flight_log_groups", "flight_logs"
  add_foreign_key "flight_log_groups", "groups"
  add_foreign_key "flight_log_users", "flight_logs"
  add_foreign_key "flight_log_users", "users"
  add_foreign_key "group_drones", "drones"
  add_foreign_key "group_drones", "groups"
  add_foreign_key "group_users", "groups"
  add_foreign_key "group_users", "users"
  add_foreign_key "problem_fields", "flight_logs"
  add_foreign_key "problem_fields", "users"
  add_foreign_key "problems_fields", "flight_logs"
  add_foreign_key "problems_fields", "users"
end
