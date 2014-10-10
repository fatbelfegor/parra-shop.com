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

ActiveRecord::Schema.define(version: 20141009221247) do

  create_table "categories", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "position"
    t.string   "header"
    t.text     "images"
    t.integer  "parent_id"
    t.string   "s_title"
    t.string   "s_description"
    t.string   "s_keyword"
    t.string   "s_name"
    t.string   "scode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "commission",    precision: 18, scale: 2, default: 0.0
    t.decimal  "rate",          precision: 18, scale: 2, default: 0.0
    t.text     "seo_text"
  end

  create_table "categories_products", id: false, force: true do |t|
    t.integer "category_id"
    t.integer "product_id"
  end

  create_table "order_items", force: true do |t|
    t.integer  "product_id",                                          null: false
    t.integer  "quantity",                                            null: false
    t.decimal  "price",        precision: 18, scale: 2, default: 0.0, null: false
    t.string   "size"
    t.string   "color"
    t.string   "option"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_id"
    t.string   "size_scode"
    t.string   "color_scode"
    t.string   "option_scode"
    t.decimal  "discount",     precision: 10, scale: 0, default: 0
  end

  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree
  add_index "order_items", ["product_id"], name: "index_order_items_on_product_id", using: :btree

  create_table "orders", force: true do |t|
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "gender"
    t.string   "phone"
    t.string   "email"
    t.string   "pay_type"
    t.string   "addr_street"
    t.string   "addr_home"
    t.string   "addr_block"
    t.string   "addr_flat"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "status"
    t.string   "salon"
    t.string   "salon_tel"
    t.string   "manager"
    t.string   "manager_tel"
    t.string   "addr_metro"
    t.string   "addr_staircase"
    t.string   "addr_floor"
    t.string   "addr_code"
    t.string   "addr_elevator"
    t.string   "deliver_type"
    t.decimal  "deliver_cost",      precision: 10, scale: 0
    t.string   "prepayment_date"
    t.decimal  "prepayment_sum",    precision: 10, scale: 0
    t.string   "doppayment_date"
    t.decimal  "doppayment_sum",    precision: 10, scale: 0
    t.string   "finalpayment_date"
    t.decimal  "finalpayment_sum",  precision: 10, scale: 0
    t.string   "payment_type"
    t.decimal  "credit_sum",        precision: 10, scale: 0
    t.integer  "credit_month"
    t.decimal  "credit_procent",    precision: 10, scale: 0
    t.string   "deliver_date"
  end

  create_table "prcolors", force: true do |t|
    t.integer  "product_id"
    t.string   "scode"
    t.string   "name"
    t.decimal  "price",       precision: 18, scale: 2, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
    t.string   "images"
  end

  create_table "products", force: true do |t|
    t.integer  "category_id"
    t.string   "scode"
    t.string   "name"
    t.text     "description"
    t.text     "images"
    t.text     "shortdesk"
    t.boolean  "delemiter"
    t.boolean  "invisible"
    t.boolean  "main"
    t.boolean  "action"
    t.boolean  "best"
    t.integer  "position"
    t.string   "s_title"
    t.string   "s_description"
    t.string   "s_keyword"
    t.string   "s_imagealt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price",         precision: 18, scale: 2, default: 0.0
    t.text     "seo_text"
    t.decimal  "old_price",     precision: 18, scale: 2, default: 0.0
  end

  create_table "proptions", force: true do |t|
    t.integer  "product_id"
    t.string   "scode"
    t.string   "name"
    t.decimal  "price",      precision: 18, scale: 2, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prsizes", force: true do |t|
    t.integer  "product_id"
    t.string   "scode"
    t.string   "name"
    t.decimal  "price",      precision: 18, scale: 2, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "textures", force: true do |t|
    t.integer  "prcolor_id"
    t.string   "scode"
    t.string   "name"
    t.string   "image"
    t.decimal  "price",      precision: 18, scale: 2, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
