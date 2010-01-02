class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.column :building,     :string
      t.column :room,         :string
      t.column :directions,   :string
      t.column :hashed_id,    :integer,     :default => 0
      t.column :lock_version, :integer, :default=>0
      t.timestamps
    end
    
     add_index :locations, :hashed_id
  end

  def self.down
    drop_table :locations
  end
end
