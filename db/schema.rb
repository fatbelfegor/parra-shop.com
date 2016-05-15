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

ActiveRecord::Schema.define(version: 20160515203706) do

  create_table "banners", force: :cascade do |t|
    t.string   "image",        limit: 255
    t.string   "url",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "second_line",              default: false
    t.boolean  "third_line",               default: false
    t.boolean  "square_third",             default: false
    t.boolean  "fourth_line",              default: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.text     "description",      limit: 65535
    t.integer  "position",         limit: 4
    t.string   "header",           limit: 255
    t.text     "images",           limit: 65535
    t.integer  "parent_id",        limit: 4
    t.string   "s_title",          limit: 255
    t.string   "s_description",    limit: 255
    t.string   "s_keyword",        limit: 255
    t.string   "s_name",           limit: 255
    t.string   "scode",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "commission",                     precision: 18, scale: 2, default: 0.0
    t.decimal  "rate",                           precision: 18, scale: 2, default: 0.0
    t.text     "seo_text",         limit: 65535
    t.string   "url",              limit: 255
    t.boolean  "menu"
    t.boolean  "isMobile",                                                default: false
    t.string   "mobile_image_url", limit: 255
  end

  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree

  create_table "categories_products", id: false, force: :cascade do |t|
    t.integer "category_id", limit: 4, null: false
    t.integer "product_id",  limit: 4, null: false
  end

  add_index "categories_products", ["category_id"], name: "index_categories_products_on_category_id", using: :btree
  add_index "categories_products", ["product_id"], name: "index_categories_products_on_product_id", using: :btree

  create_table "color_categories", force: :cascade do |t|
    t.integer  "category_id", limit: 4
    t.string   "image",       limit: 255
    t.string   "url",         limit: 255
    t.string   "name",        limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "color_categories", ["category_id"], name: "index_color_categories_on_category_id", using: :btree
  add_index "color_categories", ["url"], name: "index_color_categories_on_url", using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.text     "body",       limit: 65535
    t.string   "author",     limit: 255
    t.boolean  "published",                default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "city",       limit: 255
    t.datetime "date"
    t.text     "response",   limit: 65535
  end

  create_table "extensions", force: :cascade do |t|
    t.string "name",  limit: 255
    t.string "image", limit: 255
  end

  create_table "manager_logs", force: :cascade do |t|
    t.string   "action",        limit: 255
    t.integer  "order_id",      limit: 4
    t.integer  "order_item_id", limit: 4
    t.integer  "user_id",       limit: 4
    t.datetime "time"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer  "product_id",   limit: 4,                                          null: false
    t.integer  "quantity",     limit: 4,                                          null: false
    t.decimal  "price",                    precision: 18, scale: 2, default: 0.0, null: false
    t.string   "size",         limit: 255
    t.string   "color",        limit: 255
    t.string   "option",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_id",     limit: 4
    t.string   "size_scode",   limit: 255
    t.string   "color_scode",  limit: 255
    t.string   "option_scode", limit: 255
    t.decimal  "discount",                 precision: 10,           default: 0
  end

  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree
  add_index "order_items", ["product_id"], name: "index_order_items_on_product_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.string   "first_name",        limit: 255
    t.string   "middle_name",       limit: 255
    t.string   "last_name",         limit: 255
    t.string   "gender",            limit: 255
    t.string   "phone",             limit: 255
    t.string   "email",             limit: 255
    t.string   "pay_type",          limit: 255
    t.string   "addr_street",       limit: 255
    t.string   "addr_home",         limit: 255
    t.string   "addr_block",        limit: 255
    t.string   "addr_flat",         limit: 255
    t.text     "comment",           limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "salon",             limit: 255
    t.string   "salon_tel",         limit: 255
    t.string   "manager",           limit: 255
    t.string   "manager_tel",       limit: 255
    t.string   "addr_metro",        limit: 255
    t.string   "addr_staircase",    limit: 255
    t.string   "addr_floor",        limit: 255
    t.string   "addr_code",         limit: 255
    t.string   "addr_elevator",     limit: 255
    t.string   "deliver_type",      limit: 255
    t.decimal  "deliver_cost",                    precision: 10, default: 0
    t.string   "prepayment_date",   limit: 255
    t.decimal  "prepayment_sum",                  precision: 10, default: 0
    t.string   "doppayment_date",   limit: 255
    t.decimal  "doppayment_sum",                  precision: 10, default: 0
    t.string   "finalpayment_date", limit: 255
    t.decimal  "finalpayment_sum",                precision: 10, default: 0
    t.string   "payment_type",      limit: 255
    t.decimal  "credit_sum",                      precision: 10, default: 0
    t.integer  "credit_month",      limit: 4
    t.decimal  "credit_procent",                  precision: 10, default: 0
    t.string   "deliver_date",      limit: 255
    t.integer  "status_id",         limit: 4
    t.integer  "number",            limit: 4
  end

  create_table "packinglistitems", force: :cascade do |t|
    t.integer "packinglist_id",       limit: 4
    t.integer "product_id",           limit: 4
    t.string  "product_name_article", limit: 255
    t.integer "amount",               limit: 4
    t.decimal "price",                            precision: 18, scale: 2
    t.string  "name",                 limit: 255
  end

  create_table "packinglists", force: :cascade do |t|
    t.string "doc_number", limit: 255
    t.date   "date"
    t.string "user",       limit: 255
  end

  create_table "prcolors", force: :cascade do |t|
    t.integer  "product_id",  limit: 4
    t.string   "scode",       limit: 255
    t.string   "name",        limit: 255
    t.decimal  "price",                   precision: 18, scale: 2, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description", limit: 255
    t.string   "images",      limit: 255
    t.integer  "prsize_id",   limit: 4
  end

  add_index "prcolors", ["prsize_id"], name: "index_prcolors_on_prsize_id", using: :btree

  create_table "product_footer_images", force: :cascade do |t|
    t.string  "image",      limit: 255
    t.integer "product_id", limit: 4
  end

  create_table "products", force: :cascade do |t|
    t.integer  "category_id",       limit: 4
    t.string   "scode",             limit: 255
    t.string   "name",              limit: 255
    t.text     "description",       limit: 65535
    t.text     "images",            limit: 65535
    t.text     "shortdesk",         limit: 65535
    t.boolean  "delemiter"
    t.boolean  "invisible"
    t.boolean  "main"
    t.boolean  "action"
    t.boolean  "best"
    t.integer  "position",          limit: 4
    t.string   "s_title",           limit: 255
    t.string   "s_description",     limit: 255
    t.string   "s_keyword",         limit: 255
    t.string   "s_imagealt",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price",                           precision: 18, scale: 2, default: 0.0
    t.text     "seo_text",          limit: 65535
    t.decimal  "old_price",                       precision: 18, scale: 2, default: 0.0
    t.string   "seo_title2",        limit: 255
    t.integer  "subcategory_id",    limit: 4
    t.string   "article",           limit: 255
    t.integer  "extension_id",      limit: 4
    t.integer  "color_category_id", limit: 4
    t.integer  "color_position",    limit: 4,                              default: 0
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["extension_id"], name: "index_products_on_extension_id", using: :btree
  add_index "products", ["subcategory_id"], name: "index_products_on_subcategory_id", using: :btree

  create_table "proptions", force: :cascade do |t|
    t.integer  "product_id", limit: 4
    t.string   "scode",      limit: 255
    t.string   "name",       limit: 255
    t.decimal  "price",                  precision: 18, scale: 2, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "prsize_id",  limit: 4
  end

  add_index "proptions", ["prsize_id"], name: "index_proptions_on_prsize_id", using: :btree

  create_table "prsizes", force: :cascade do |t|
    t.integer  "product_id", limit: 4
    t.string   "scode",      limit: 255
    t.string   "name",       limit: 255
    t.decimal  "price",                  precision: 18, scale: 2, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "old_price",              precision: 10, scale: 2, default: 0.0
  end

  create_table "statuses", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "sub_cat_images", force: :cascade do |t|
    t.string  "url",            limit: 255
    t.text    "description",    limit: 65535
    t.integer "subcategory_id", limit: 4
  end

  add_index "sub_cat_images", ["subcategory_id"], name: "index_sub_cat_images_on_subcategory_id", using: :btree

  create_table "subcategories", force: :cascade do |t|
    t.string  "name",        limit: 255
    t.text    "description", limit: 65535
    t.integer "category_id", limit: 4
  end

  add_index "subcategories", ["category_id"], name: "index_subcategories_on_category_id", using: :btree

  create_table "textures", force: :cascade do |t|
    t.integer  "prcolor_id", limit: 4
    t.string   "scode",      limit: 255
    t.string   "name",       limit: 255
    t.string   "image",      limit: 255
    t.decimal  "price",                  precision: 18, scale: 2, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "color_id",   limit: 4
  end

  add_index "textures", ["color_id"], name: "index_textures_on_color_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
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
    t.boolean  "admin"
    t.boolean  "manager"
    t.string   "prefix",                 limit: 255
    t.string   "role",                   limit: 255
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "virtproducts", force: :cascade do |t|
    t.text    "text",     limit: 65535
    t.decimal "price",                  precision: 18, scale: 2, default: 0.0, null: false
    t.integer "order_id", limit: 4
  end

end
