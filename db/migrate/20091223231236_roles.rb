class Roles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column :hashed_id,                 :integer, :default => 0
      t.column :name,                      :string, :default => nil
      t.column :slug,                      :string, :default => nil
      t.column :description,               :string, :default => nil
      t.column :lock_version,              :int, :default => 0
      t.column :hashed_id,                 :integer,   :default => 0
      t.timestamps
    end   
    
    create_table :privileges do |t|
      t.column :hashed_id,                 :integer, :default => 0
      t.column :role_id,        :int, :default => 0
      t.column :user_id,        :int, :default => 0
      t.column :lock_version,              :int, :default => 0
      t.column :modified_by_user_id,       :int
      t.column :hashed_id,      :integer,   :default => 0
      t.timestamps
    end
    add_index :privileges, :hashed_id
    add_index :roles, :hashed_id
    add_index :privileges, :role_id
    add_index :privileges, :user_id
    
    admin = Role.new({:name => "Administrator", :description => "Administrative role"})
    admin.slug = "admin"
    admin.save!
    exp = Role.new({:name => "Experimenter", :description => "Experimenter role"})
    exp.slug = "experimenter"
    exp.save!
  end

  def self.down
     drop_table "roles"
     drop_table "privileges"
  end
end
