class CreateSlots < ActiveRecord::Migration
  def self.up
    create_table :slots do |t|
      t.column :subject_id,   :int
      t.column :experiment_id, :int
      t.column :time,         :datetime
      t.column :hashed_id,   :integer,     :default => 0
      t.column :cancelled,   :boolean, :default => false
      t.column :scheduled_in_background, :boolean, :default => false
      t.timestamps
      t.column :lock_version, :integer, :default=>0
    end
    
    add_index :slots, :subject_id
    add_index :slots, :experiment_id
    add_index :slots, :hashed_id
  end

  def self.down
    drop_table :slots
  end
end
