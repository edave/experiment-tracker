class CreateExperiments < ActiveRecord::Migration
  def self.up
    create_table :experiments do |t|
      t.column :name, :string, :limit => 256
      t.column :desc, :blob
      t.column :hashed_id,   :integer,     :default => 0
      t.column :time_length, :int
      t.timestamps
    end
  end

  def self.down
    drop_table :experiments
  end
end
