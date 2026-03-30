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

ActiveRecord::Schema[8.1].define(version: 2026_03_30_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "vehicle_api_request_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration_ms"
    t.string "http_method", null: false
    t.string "ip"
    t.jsonb "metadata"
    t.string "origin"
    t.jsonb "params"
    t.string "path", null: false
    t.string "referer"
    t.string "request_id"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "vehicle_id"
    t.index ["created_at"], name: "index_vehicle_api_request_logs_on_created_at"
    t.index ["ip"], name: "index_vehicle_api_request_logs_on_ip"
    t.index ["path"], name: "index_vehicle_api_request_logs_on_path"
    t.index ["request_id"], name: "index_vehicle_api_request_logs_on_request_id"
    t.index ["vehicle_id", "created_at"], name: "index_vehicle_api_request_logs_on_vehicle_id_and_created_at"
    t.index ["vehicle_id"], name: "index_vehicle_api_request_logs_on_vehicle_id"
  end

  create_table "vehicle_api_vehicles", force: :cascade do |t|
    t.string "body"
    t.datetime "created_at", null: false
    t.string "external_id"
    t.string "fuel_type"
    t.string "image_url"
    t.string "make"
    t.string "model"
    t.string "name"
    t.jsonb "raw_data"
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["external_id"], name: "index_vehicle_api_vehicles_on_external_id", unique: true
  end

  add_foreign_key "vehicle_api_request_logs", "vehicle_api_vehicles", column: "vehicle_id"
end
