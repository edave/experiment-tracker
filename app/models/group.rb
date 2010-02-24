class Group < ActiveRecord::Base
  acts_as_deactivated
  has_hashed_id
  
  has_many :users
  
  # Validations
  validates_presence_of     :name
  
  validates_uniqueness_of   :logo_file_name
  validates_uniqueness_of   :name, :case_sensitive => false
end
