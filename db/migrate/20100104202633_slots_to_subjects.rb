class SlotsToSubjects < ActiveRecord::Migration
  def self.up
    create_table :slots_subjects, :id => false do |t|
      t.column :subject_id, :int
      t.column :slot_id, :int
    end
    remove_column :slots, :subject_id
    remove_column :slots, :scheduled_in_background
    add_column :experiments, :num_subjects_per_slot, :int, :default => 1
    add_column :slots, :subjects_count, :int, :default => 0
    add_column :subjects, :scheduled_in_background, :boolean, :default => false
      
    add_index :slots, :time
    add_index :slots_subjects, :subject_id
    add_index :slots_subjects, :slot_id
  end

  def self.down
    drop_table :slots_subjects 
    remove_column :experiments, :num_subjects_per_slot
    remove_column :slots, :subjects_count
    add_column :slots, :subject_id, :int
    remove_index :slots, :time
  end
end
