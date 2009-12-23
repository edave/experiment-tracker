class CreateSubjects < ActiveRecord::Migration
  def self.up
    create_table :subjects do |t|
      t.column :encrypted_email,               :string
      t.column :encrypted_name,                :string
      t.column :encrypted_phone_number,        :string
      t.column :hashed_id,   :integer,     :default => 0
      t.timestamps
      t.column :lock_version, :integer, :default=>0
    end
    add_index :subjects, :hashed_id
    
  end

  def self.down
    drop_table :subjects
  end
end
