class ExperimentOwner < ActiveRecord::Migration
  def self.up
    add_column :experiments, :user_id,   :integer, :default => 0
    add_column :experiments, :slot_close_time, :integer, :default => 0
    add_column :experiments, :visible_days_before, :integer, :default => 0
  end

  def self.down
    remove_column :experiments, :user_id
    remove_column :experiments, :slot_close_time
    remove_column :experiments, :visible_days_before
  end
end
