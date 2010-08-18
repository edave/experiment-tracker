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

ActiveRecord::Schema.define(:version => 20100223232238) do

  create_table "appointments", :force => true do |t|
    t.integer  "subject_id"
    t.integer  "slot_id"
    t.boolean  "scheduled_in_background", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "appointments", ["slot_id"], :name => "index_appointments_on_slot_id"
  add_index "appointments", ["subject_id"], :name => "index_appointments_on_subject_id"

  create_table "experiments", :force => true do |t|
    t.string   "name",                  :limit => 256
    t.binary   "desc"
    t.integer  "hashed_id",                            :default => 0
    t.integer  "time_length"
    t.integer  "user_id",                              :default => 0
    t.integer  "location_id",                          :default => 0
    t.integer  "slot_close_time",                      :default => 0
    t.integer  "num_subjects",                         :default => 0
    t.integer  "compensation",                         :default => 0
    t.boolean  "open",                                 :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                         :default => 0
    t.integer  "google_calendar_id"
    t.integer  "num_subjects_per_slot",                :default => 1
  end

  add_index "experiments", ["hashed_id"], :name => "index_experiments_on_hashed_id"
  add_index "experiments", ["open"], :name => "index_experiments_on_open"
  add_index "experiments", ["user_id"], :name => "index_experiments_on_user_id"

  create_table "google_calendars", :force => true do |t|
    t.string   "encrypted_login"
    t.string   "encrypted_password"
    t.string   "calendar_id"
    t.string   "name"
    t.integer  "hashed_id",          :default => 0
    t.integer  "lock_version",       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "google_calendars", ["hashed_id"], :name => "index_google_calendars_on_hashed_id"

  create_table "groups", :force => true do |t|
    t.integer  "owner_id",        :default => 0
    t.string   "name"
    t.string   "url"
    t.string   "logo_file_name"
    t.string   "logo_file_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer  "hashed_id",       :default => 0
    t.integer  "lock_version",    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["hashed_id"], :name => "index_groups_on_hashed_id"
  add_index "groups", ["owner_id"], :name => "index_groups_on_owner_id"

  create_table "locations", :force => true do |t|
    t.string   "building"
    t.string   "room"
    t.string   "directions"
    t.integer  "hashed_id",    :default => 0
    t.integer  "lock_version", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["hashed_id"], :name => "index_locations_on_hashed_id"

  create_table "slots", :force => true do |t|
    t.integer  "experiment_id"
    t.datetime "time"
    t.integer  "hashed_id",          :default => 0
    t.boolean  "cancelled",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",       :default => 0
    t.integer  "subjects_count",     :default => 0
    t.integer  "appointments_count", :default => 0
  end

  add_index "slots", ["experiment_id"], :name => "index_slots_on_experiment_id"
  add_index "slots", ["hashed_id"], :name => "index_slots_on_hashed_id"
  add_index "slots", ["time"], :name => "index_slots_on_time"

  create_table "slots_subjects", :id => false, :force => true do |t|
    t.integer "subject_id"
    t.integer "slot_id"
  end

  add_index "slots_subjects", ["slot_id"], :name => "index_slots_subjects_on_slot_id"
  add_index "slots_subjects", ["subject_id"], :name => "index_slots_subjects_on_subject_id"

  create_table "subjects", :force => true do |t|
    t.string   "encrypted_email"
    t.string   "encrypted_name"
    t.string   "encrypted_phone_number"
    t.integer  "hashed_id",              :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",           :default => 0
    t.integer  "appointments_count",     :default => 0
  end

  add_index "subjects", ["hashed_id"], :name => "index_subjects_on_hashed_id"

  create_table "users", :force => true do |t|
    t.integer  "hashed_id",                           :default => 0
    t.string   "name",                 :limit => 100
    t.string   "phone",                :limit => 20
    t.string   "user_name",            :limit => 40
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",                     :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id",                            :default => 0
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["hashed_id"], :name => "index_users_on_hashed_id", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true
  add_index "users", ["user_name"], :name => "index_users_on_user_name", :unique => true

end
