class CreateSubjects < ActiveRecord::Migration
  def self.up
    create_table :subjects do |t|
      t.column :email,                     :string, :limit => 256
      t.column :name,                :string, :limit => 60
      t.column :phone_number,       :string, :limit => 30
      t.column  :hashed_id,   :integer,     :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :subjects
  end
end
