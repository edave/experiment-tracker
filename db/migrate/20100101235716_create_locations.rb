class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.column :building,     :string
      t.column :room,         :string
      t.column :directions,   :string
      t.column :lock_version, :integer, :default=>0
      t.timestamps
    end
    
  end

  def self.down
    drop_table :locations
  end
end
