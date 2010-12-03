class Users < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.column :name,                      :string, :limit => 100
      t.column :phone,                     :string, :limit => 20
      t.string :user_name,                 :limit => 40

      # Devise  columns
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable
      t.confirmable
      t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      t.token_authenticatable

      t.timestamps
    end
    add_index :users, :user_name,            :unique => true
    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :confirmation_token,   :unique => true
    add_index :users, :unlock_token,         :unique => true

  end

  def self.down
    drop_table(:users)
  end
end
