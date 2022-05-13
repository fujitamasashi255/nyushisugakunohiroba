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

ActiveRecord::Schema.define(version: 2022_05_06_122914) do

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
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "university_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["university_id"], name: "index_departments_on_university_id"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "year", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "questions_departments_mediators", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "department_id", null: false
    t.integer "question_number", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["department_id"], name: "index_questions_departments_mediators_on_department_id"
    t.index ["question_id", "department_id"], name: "index_questions_depts_mediators_on_question_id_and_dept_id", unique: true
    t.index ["question_id"], name: "index_questions_departments_mediators_on_question_id"
  end

  create_table "questions_units_mediators", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "unit_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["question_id", "unit_id"], name: "index_questions_units_mediators_on_question_id_and_unit_id", unique: true
    t.index ["question_id"], name: "index_questions_units_mediators_on_question_id"
    t.index ["unit_id"], name: "index_questions_units_mediators_on_unit_id"
  end

  create_table "texes", force: :cascade do |t|
    t.string "texable_type", null: false
    t.bigint "texable_id", null: false
    t.text "code"
    t.string "pdf_blob_signed_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["texable_type", "texable_id"], name: "index_texes_on_texable"
  end

  create_table "universities", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "prefecture_id"
    t.integer "category", default: 0, null: false
    t.index ["name"], name: "index_universities_on_name", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "departments", "universities"
  add_foreign_key "questions_departments_mediators", "departments"
  add_foreign_key "questions_departments_mediators", "questions"
  add_foreign_key "questions_units_mediators", "questions"
end
