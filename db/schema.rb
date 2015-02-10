# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150207001030) do

  create_table "categories", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "scode",       limit: 255
    t.integer  "category_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "categories", ["category_id"], name: "index_categories_on_category_id", using: :btree

  create_table "categories_products", id: false, force: :cascade do |t|
    t.integer "category_id", limit: 4
    t.integer "product_id",  limit: 4
  end

  create_table "images", force: :cascade do |t|
    t.string  "url",            limit: 255
    t.integer "imageable_id",   limit: 4
    t.string  "imageable_type", limit: 255
  end

  add_index "images", ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id", using: :btree

  create_table "packinglistitems", force: :cascade do |t|
    t.integer "packinglist_id",       limit: 4
    t.integer "product_id",           limit: 4
    t.string  "product_name_article", limit: 255
    t.integer "amount",               limit: 4
    t.decimal "price",                            precision: 10
    t.string  "name",                 limit: 255
  end

  add_index "packinglistitems", ["packinglist_id"], name: "index_packinglistitems_on_packinglist_id", using: :btree
  add_index "packinglistitems", ["product_id"], name: "index_packinglistitems_on_product_id", using: :btree

  create_table "packinglists", force: :cascade do |t|
    t.string "doc_number", limit: 255
    t.date   "date"
    t.string "user",       limit: 255
  end

  create_table "products", force: :cascade do |t|
    t.string  "name",            limit: 255,                                           null: false
    t.string  "scode",           limit: 255,                                           null: false
    t.string  "article",         limit: 255
    t.string  "s_title",         limit: 255
    t.text    "description",     limit: 65535
    t.text    "short_desc",      limit: 65535
    t.decimal "price",                         precision: 8, scale: 2,                 null: false
    t.decimal "old_price",                     precision: 8, scale: 2
    t.string  "seo_title",       limit: 255
    t.text    "seo_description", limit: 65535
    t.string  "seo_keywords",    limit: 255
    t.integer "position",        limit: 4
    t.boolean "invisible",       limit: 1,                             default: false, null: false
  end

  add_index "products", ["scode"], name: "index_products_on_scode", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "role",                   limit: 255
    t.string   "prefix",                 limit: 255
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "categories", "categories"
end
