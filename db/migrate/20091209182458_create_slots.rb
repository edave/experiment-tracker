class CreateSlots < ActiveRecord::Migration
  def self.up
    create_table :slots do |t|
      t.column :subject_id,   :int
      t.column :experiment_id, :int
      t.column :time,         :datetime
      t.column :hashed_id,   :integer,     :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :slots
  end
end
