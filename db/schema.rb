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

ActiveRecord::Schema[8.1].define(version: 2026_02_22_200004) do
  create_table "exercise_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "exercise_id", null: false
    t.text "notes"
    t.datetime "performed_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.decimal "value", precision: 10, scale: 2, null: false
    t.index ["exercise_id"], name: "index_exercise_logs_on_exercise_id"
    t.index ["user_id", "exercise_id"], name: "index_exercise_logs_on_user_id_and_exercise_id"
    t.index ["user_id", "performed_at"], name: "index_exercise_logs_on_user_id_and_performed_at"
    t.index ["user_id"], name: "index_exercise_logs_on_user_id"
  end

  create_table "exercises", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "exercise_type", default: "reps", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_exercises_on_slug", unique: true
  end

  create_table "food_logs", force: :cascade do |t|
    t.datetime "consumed_at", null: false
    t.datetime "created_at", null: false
    t.integer "food_id", null: false
    t.text "notes"
    t.string "unit", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.decimal "value", precision: 10, scale: 2, null: false
    t.index ["food_id"], name: "index_food_logs_on_food_id"
    t.index ["user_id", "consumed_at"], name: "index_food_logs_on_user_id_and_consumed_at"
    t.index ["user_id", "food_id"], name: "index_food_logs_on_user_id_and_food_id"
    t.index ["user_id"], name: "index_food_logs_on_user_id"
  end

  create_table "foods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "default_serving", precision: 10, scale: 2
    t.string "default_unit", default: "grams", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_foods_on_slug", unique: true
  end

  create_table "hrv_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "value", null: false
    t.index ["user_id", "date"], name: "index_hrv_entries_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_hrv_entries_on_user_id"
  end

  create_table "journal_entries", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "recorded_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "recorded_at"], name: "index_journal_entries_on_user_id_and_recorded_at"
    t.index ["user_id"], name: "index_journal_entries_on_user_id"
  end

  create_table "journal_entry_labels", force: :cascade do |t|
    t.integer "journal_entry_id", null: false
    t.integer "label_id", null: false
    t.index ["journal_entry_id", "label_id"], name: "index_journal_entry_labels_on_journal_entry_id_and_label_id", unique: true
    t.index ["journal_entry_id"], name: "index_journal_entry_labels_on_journal_entry_id"
    t.index ["label_id"], name: "index_journal_entry_labels_on_label_id"
  end

  create_table "labels", force: :cascade do |t|
    t.string "color", default: "gray", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_labels_on_slug", unique: true
  end

  create_table "measurements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.integer "metric_id", null: false
    t.text "notes"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.decimal "value", precision: 10, scale: 2, null: false
    t.index ["metric_id"], name: "index_measurements_on_metric_id"
    t.index ["user_id", "metric_id", "date"], name: "index_measurements_on_user_id_and_metric_id_and_date", unique: true
    t.index ["user_id"], name: "index_measurements_on_user_id"
  end

  create_table "metrics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "daily_loggable", default: false, null: false
    t.boolean "delta_down_is_good", default: false, null: false
    t.string "name", null: false
    t.decimal "reference_max", precision: 10, scale: 2
    t.decimal "reference_min", precision: 10, scale: 2
    t.string "slug", null: false
    t.string "units"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_metrics_on_slug", unique: true
  end

  create_table "rhr_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "value", null: false
    t.index ["user_id", "date"], name: "index_rhr_entries_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_rhr_entries_on_user_id"
  end

  create_table "step_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "value", null: false
    t.index ["user_id", "date"], name: "index_step_entries_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_step_entries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "api_token"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "weight_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.decimal "value", precision: 5, scale: 1, null: false
    t.index ["user_id", "date"], name: "index_weight_entries_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_weight_entries_on_user_id"
  end

  add_foreign_key "exercise_logs", "exercises"
  add_foreign_key "exercise_logs", "users"
  add_foreign_key "food_logs", "foods"
  add_foreign_key "food_logs", "users"
  add_foreign_key "hrv_entries", "users"
  add_foreign_key "journal_entries", "users"
  add_foreign_key "journal_entry_labels", "journal_entries"
  add_foreign_key "journal_entry_labels", "labels"
  add_foreign_key "measurements", "metrics"
  add_foreign_key "measurements", "users"
  add_foreign_key "rhr_entries", "users"
  add_foreign_key "step_entries", "users"
  add_foreign_key "weight_entries", "users"
end
