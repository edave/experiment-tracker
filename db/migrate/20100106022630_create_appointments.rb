class CreateAppointments < ActiveRecord::Migration
  def self.up
    create_table :appointments do |t|
      t.column :subject_id, :int
      t.column :slot_id, :int
      t.column :scheduled_in_background, :boolean, :default => false
      t.timestamps
    end
    remove_column :subjects, :scheduled_in_background
    
    add_column :subjects, :appointments_count, :integer, :default => 0
    add_column :slots,    :appointments_count, :integer, :default => 0
    
    add_index :appointments, :subject_id
    add_index :appointments, :slot_id
  end

  def self.down
    drop_table :appointments
    add_column :subjects, :scheduled_in_background, :boolean
    remove_column :subjects, :appointments_count
    remove_column :slots, :appointments_count
  end
end
