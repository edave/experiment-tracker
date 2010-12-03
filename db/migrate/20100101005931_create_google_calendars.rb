class CreateGoogleCalendars < ActiveRecord::Migration
  def self.up
    create_table :google_calendars do |t|
      t.column :encrypted_login,           :string
      t.column :encrypted_password,        :string
      t.column :calendar_id,               :string
      t.column :name,                      :string
      t.column :lock_version, :integer, :default=>0
      t.timestamps
    end
    add_column :experiments, :google_calendar_id, :int
  end

  def self.down
    drop_table :google_calendars
    remove_column :experiments, :google_calendar_id
  end
end
