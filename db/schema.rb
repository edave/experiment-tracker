# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091215004211) do

  create_table "experiments", :force => true do |t|
    t.string   "name",            :limit => 256
    t.binary   "desc"
    t.integer  "hashed_id",                      :default => 0
    t.integer  "time_length"
    t.integer  "user_id",                        :default => 0
    t.integer  "slot_close_time",                :default => 0
    t.integer  "num_subjects",                   :default => 0
    t.integer  "compensation",                   :default => 0
    t.boolean  "open",                           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                   :default => 0
  end

  add_index "experiments", ["hashed_id"], :name => "index_experiments_on_hashed_id"
  add_index "experiments", ["open"], :name => "index_experiments_on_open"
  add_index "experiments", ["user_id"], :name => "index_experiments_on_user_id"

  create_table "slots", :force => true do |t|
    t.integer  "subject_id"
    t.integer  "experiment_id"
    t.datetime "time"
    t.integer  "hashed_id",               :default => 0
    t.boolean  "cancelled",               :default => false
    t.boolean  "scheduled_in_background", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",            :default => 0
  end

  add_index "slots", ["experiment_id"], :name => "index_slots_on_experiment_id"
  add_index "slots", ["hashed_id"], :name => "index_slots_on_hashed_id"
  add_index "slots", ["subject_id"], :name => "index_slots_on_subject_id"

  create_table "subjects", :force => true do |t|
    t.string   "encrypted_email"
    t.string   "encrypted_name"
    t.string   "encrypted_phone_number"
    t.integer  "hashed_id",              :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",           :default => 0
  end

  add_index "subjects", ["hashed_id"], :name => "index_subjects_on_hashed_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password", :limit => 128
    t.string   "salt",               :limit => 128
    t.string   "confirmation_token", :limit => 128
    t.string   "remember_token",     :limit => 128
    t.boolean  "email_confirmed",                   :default => false, :null => false
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["admin"], :name => "index_users_on_admin"
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["id", "confirmation_token"], :name => "index_users_on_id_and_confirmation_token"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
