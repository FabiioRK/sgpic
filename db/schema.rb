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

ActiveRecord::Schema[7.1].define(version: 2024_12_01_035705) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "street"
    t.string "district"
    t.string "complement"
    t.string "postal_code"
    t.string "city"
    t.string "state"
    t.bigint "supervisor_id"
    t.bigint "coordinator_id"
    t.bigint "researcher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "student_id"
    t.index ["coordinator_id"], name: "index_addresses_on_coordinator_id"
    t.index ["researcher_id"], name: "index_addresses_on_researcher_id"
    t.index ["student_id"], name: "index_addresses_on_student_id"
    t.index ["supervisor_id"], name: "index_addresses_on_supervisor_id"
  end

  create_table "annotation_histories", force: :cascade do |t|
    t.text "annotation"
    t.bigint "project_id", null: false
    t.integer "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_annotation_histories_on_project_id"
  end

  create_table "coordinators", force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.string "academic_field"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_coordinators_on_user_id"
  end

  create_table "notice_histories", force: :cascade do |t|
    t.bigint "notice_id", null: false
    t.integer "edited_by", null: false
    t.json "changes_made", null: false
    t.datetime "edited_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notice_id"], name: "index_notice_histories_on_notice_id"
  end

  create_table "notices", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description", null: false
    t.boolean "active", default: true, null: false
    t.integer "created_by"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.string "message"
    t.boolean "read", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_notifications_on_project_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.bigint "ric_number"
    t.integer "project_type"
    t.string "institution"
    t.string "course"
    t.string "study_area"
    t.string "research_line"
    t.text "ods"
    t.string "project_title"
    t.text "project_summary"
    t.text "key_words"
    t.integer "project_status", default: 0
    t.text "annotation", default: ""
    t.datetime "feedback_date"
    t.bigint "researcher_id", null: false
    t.bigint "coordinator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "notice_id", null: false
    t.index ["coordinator_id"], name: "index_projects_on_coordinator_id"
    t.index ["notice_id"], name: "index_projects_on_notice_id"
    t.index ["researcher_id"], name: "index_projects_on_researcher_id"
    t.index ["ric_number"], name: "index_projects_on_ric_number", unique: true
  end

  create_table "researchers", force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.string "academic_field"
    t.string "cv_link"
    t.string "orcid_id"
    t.string "academic_title"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_researchers_on_user_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "name"
    t.string "social_security_number"
    t.string "identity_card_number"
    t.date "birth_date"
    t.string "phone_number"
    t.string "email"
    t.string "academic_field"
    t.string "course"
    t.integer "semester"
    t.boolean "has_subject_dependencies"
    t.boolean "is_regular_student"
    t.bigint "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_students_on_project_id"
  end

  create_table "supervisors", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_supervisors_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "coordinators"
  add_foreign_key "addresses", "researchers"
  add_foreign_key "addresses", "students"
  add_foreign_key "addresses", "supervisors"
  add_foreign_key "annotation_histories", "projects"
  add_foreign_key "coordinators", "users"
  add_foreign_key "notice_histories", "notices"
  add_foreign_key "notifications", "projects"
  add_foreign_key "notifications", "users"
  add_foreign_key "projects", "coordinators"
  add_foreign_key "projects", "notices"
  add_foreign_key "projects", "researchers"
  add_foreign_key "researchers", "users"
  add_foreign_key "students", "projects"
  add_foreign_key "supervisors", "users"
end
