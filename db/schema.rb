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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120516133803) do

  create_table "account_entries", :force => true do |t|
    t.integer  "account_id",                                  :null => false
    t.integer  "bank_entry_id",                               :null => false
    t.decimal  "ammount",       :precision => 9, :scale => 2, :null => false
    t.text     "notes"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  create_table "accounts", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "accounts", ["name"], :name => "index_accounts_on_name", :unique => true

  create_table "bank_entries", :force => true do |t|
    t.date     "date",                                      :null => false
    t.decimal  "ammount",     :precision => 9, :scale => 2, :null => false
    t.text     "notes"
    t.string   "description",                               :null => false
    t.string   "external_id"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "bank_entries", ["external_id"], :name => "index_bank_entries_on_external_id", :unique => true

end
