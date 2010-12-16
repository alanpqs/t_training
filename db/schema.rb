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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101214002714) do

  create_table "categories", :force => true do |t|
    t.string   "category"
    t.string   "target"
    t.boolean  "authorized",      :default => false
    t.integer  "user_id"
    t.text     "message"
    t.boolean  "message_sent",    :default => false
    t.string   "submitted_name"
    t.string   "submitted_group"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", :force => true do |t|
    t.string   "name"
    t.string   "country_code"
    t.string   "currency_code"
    t.string   "phone_code"
    t.integer  "region_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "countries", ["country_code"], :name => "index_countries_on_country_code", :unique => true
  add_index "countries", ["name"], :name => "index_countries_on_name", :unique => true

  create_table "media", :force => true do |t|
    t.string   "medium"
    t.boolean  "authorized",        :default => false
    t.integer  "user_id"
    t.text     "rejection_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "regions", :force => true do |t|
    t.string   "region"
    t.string   "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "representations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "vendor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.string   "salt"
    t.boolean  "admin"
    t.integer  "country_id"
    t.string   "location"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "vendor",             :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

  create_table "vendors", :force => true do |t|
    t.string   "name"
    t.integer  "country_id"
    t.string   "address"
    t.string   "website"
    t.string   "email"
    t.string   "phone"
    t.text     "description"
    t.string   "verification_code"
    t.boolean  "verified",          :default => false
    t.boolean  "inactive",          :default => false
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "show_reviews",      :default => false
  end

end
