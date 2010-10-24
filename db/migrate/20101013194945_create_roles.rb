class CreateRoles < ActiveRecord::Migration
  
  # Implements ACL9's version of Roles
  def self.up
    create_table :roles do |t|
      t.string   :name,              :limit => 40
      t.string   :authorizable_type, :limit => 40
      t.integer  :authorizable_id
      t.timestamps
    end
    
    create_table "roles_users", :id => false, :force => true do |t|
      t.references  :user
      t.references  :role
      t.timestamps
  end
  end

  def self.down
    drop_table :roles
  end
end
