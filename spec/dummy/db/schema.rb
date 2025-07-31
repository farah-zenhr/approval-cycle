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

ActiveRecord::Schema[7.2].define(version: 2025_07_31_123227) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "approval_cycle_action_takers", force: :cascade do |t|
    t.string "user_type", null: false
    t.bigint "user_id", null: false
    t.bigint "approval_cycle_setup_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approval_cycle_setup_id"], name: "index_approval_cycle_action_takers_on_approval_cycle_setup_id"
    t.index ["user_id", "user_type", "approval_cycle_setup_id"], name: "index_action_takers_on_user_id_and_setup_id", unique: true
    t.index ["user_type", "user_id"], name: "index_approval_cycle_action_takers_on_user"
  end

  create_table "approval_cycle_approvals", force: :cascade do |t|
    t.string "status"
    t.string "approvable_type"
    t.bigint "approvable_id"
    t.bigint "approval_cycle_approver_id"
    t.string "rejection_reason"
    t.datetime "received_at"
    t.index ["approvable_type", "approvable_id"], name: "index_approval_cycle_approvals_on_approvable"
    t.index ["approval_cycle_approver_id"], name: "index_approval_cycle_approvals_on_approval_cycle_approver_id"
  end

  create_table "approval_cycle_approvers", force: :cascade do |t|
    t.integer "order", null: false
    t.bigint "approval_cycle_setup_id", null: false
    t.string "user_type", null: false
    t.bigint "user_id", null: false
    t.index ["approval_cycle_setup_id"], name: "index_approval_cycle_approvers_on_approval_cycle_setup_id"
    t.index ["user_type", "user_id"], name: "index_approval_cycle_approvers_on_user"
  end

  create_table "approval_cycle_object_activities", force: :cascade do |t|
    t.string "object_type", null: false
    t.bigint "object_id", null: false
    t.string "created_by_type", null: false
    t.bigint "created_by_id", null: false
    t.string "updated_by_type"
    t.bigint "updated_by_id"
    t.datetime "updated_at"
    t.index ["created_by_type", "created_by_id"], name: "index_approval_cycle_object_activities_on_created_by"
    t.index ["object_type", "object_id"], name: "index_approval_cycle_object_activities_on_object"
    t.index ["updated_by_type", "updated_by_id"], name: "index_approval_cycle_object_activities_on_updated_by"
  end

  create_table "approval_cycle_setups", force: :cascade do |t|
    t.integer "approval_cycle_setup_type"
    t.integer "skip_after"
    t.string "name", null: false
    t.boolean "latest", default: true, null: false
    t.bigint "latest_setup_version_id"
    t.string "level_type", null: false
    t.bigint "level_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["latest_setup_version_id"], name: "index_approval_cycle_setups_on_latest_setup_version_id"
    t.index ["level_type", "level_id"], name: "index_approval_cycle_setups_on_level"
    t.index ["name"], name: "index_approval_cycle_setups_on_name"
  end

  create_table "approval_cycle_watchers", force: :cascade do |t|
    t.integer "action"
    t.string "user_type", null: false
    t.bigint "user_id", null: false
    t.bigint "approval_cycle_setup_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approval_cycle_setup_id"], name: "index_approval_cycle_watchers_on_approval_cycle_setup_id"
    t.index ["user_id", "user_type", "approval_cycle_setup_id", "action"], name: "index_watchers_on_user_id_and_setup_id_and_action", unique: true
    t.index ["user_type", "user_id"], name: "index_approval_cycle_watchers_on_user"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dummy_requests", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "approval_cycle_setup_id"
    t.integer "approval_cycle_status"
    t.boolean "is_approval_cycle_reset", default: false
    t.index ["approval_cycle_setup_id"], name: "index_dummy_requests_on_approval_cycle_setup_id"
  end

  create_table "dummy_users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "approval_cycle_action_takers", "approval_cycle_setups"
  add_foreign_key "approval_cycle_approvals", "approval_cycle_approvers"
  add_foreign_key "approval_cycle_approvers", "approval_cycle_setups"
  add_foreign_key "approval_cycle_setups", "approval_cycle_setups", column: "latest_setup_version_id"
  add_foreign_key "approval_cycle_watchers", "approval_cycle_setups"
  add_foreign_key "dummy_requests", "approval_cycle_setups"
end
