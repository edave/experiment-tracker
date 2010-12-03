class CreateExperiments < ActiveRecord::Migration
  def self.up
    create_table :experiments do |t|
      t.column :name, :string, :limit => 256
      t.column :desc, :blob
      t.column :time_length, :int
      t.column :user_id,   :integer, :default => 0
      t.column :location_id, :integer, :default => 0
      t.column :slot_close_time, :integer, :default => 0
      t.column :num_subjects, :integer, :default => 0
      t.column :compensation, :integer, :default => 0
      t.column :open, :boolean, :default => false
      t.timestamps
      t.column :lock_version, :integer, :default=>0
    end
    
    add_index :experiments, :user_id
    add_index :experiments, :open
  end

  def self.down
    drop_table :experiments
  end
end
