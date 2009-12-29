class Users < ActiveRecord::Migration
  def self.up
    create_table "users" do |t|
      t.column :hashed_id,                 :integer, :default => 0
      t.column :login,                     :string, :limit => 40
      t.column :name,                      :string, :limit => 100
      t.column :phone,                     :string, :limit => 20
      t.column :email,                     :string, :limit => 256
      t.column :crypted_password,          :string, :limit => 64, :default => nil
      t.column :salt,                      :string, :limit => 64, :default => nil
      t.column :remember_token,            :string, :default => nil
      t.column :remember_token_expires_at, :datetime, :default => nil
      
      t.column :last_authenticated_at,     :datetime, :default => nil
      t.column :last_authenticated_ip,     :string, :default => nil
      
      t.column :activation_code,           :string, :limit => 64
      t.column :activated_at,              :datetime, :default => nil
      
      t.column :recover_requested,         :boolean, :default => false
      t.column :recover_requested_at,      :datetime, :default => nil
      t.column :recover_code,              :string, :limit => 64, :default => nil
      t.column :recover_in_process_code,   :string, :limit => 64, :default => nil
      
      t.column :failure,                   :int, :default => 0
      t.column :last_failed_at,            :datetime, :default => nil
      t.column :last_failed_ip,            :string, :default => nil
      
      t.column :eula_version, :integer, :default => 0
      
      t.column :frozen_in_db,  :boolean,   :default => false
      t.column :deactivated_at,  :datetime,   :default => nil
      
      t.column :lock_version,              :int, :default => 0
      t.timestamps
    end
    add_index :users, :login
    add_index :users, :hashed_id
    add_index :users, :email
    add_index :users, :remember_token
  end

  def self.down
    drop_table "users"
  end
end
