class SlotCancelled < ActiveRecord::Migration
  def self.up
    add_column :slots, :cancelled,   :boolean, :default => false
    
  end

  def self.down
    remove_column :slots, :cancelled
  end
end
