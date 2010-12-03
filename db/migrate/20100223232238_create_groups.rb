class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.column :owner_id, :integer, :default => 0
      t.column :name, :string
      t.column :url, :string
      t.column :logo_file_name, :string
      t.column :logo_file_type, :string
      t.column :logo_file_size, :integer
      t.column :logo_updated_at, :datetime
      t.column :lock_version, :integer, :default=>0
      t.timestamps
    end
    add_column :users, :group_id, :integer, :default => 0
    add_index :groups, :owner_id
    
  end

  def self.down
    remove_column :users, :group_id
    drop_table :groups
  end
end
