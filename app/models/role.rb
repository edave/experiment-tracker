class Role < ObfuscatedRecord
  # A Role represents a group of Users who may perform certain actions
  # within the Authorization system
  
  # Slugs are used as the UID for Roles since hardcoding database key IDs can
  # be very brittle and difficult to work with.
  # After a role is created, its slug cannot be changed, so we assume
  # the slug is a safe identified of the Role object in the database
  
  
  has_many :privileges
  
  validates_presence_of     :name, :slug, :description
  validates_uniqueness_of   :name, :slug, :description, :case_sensitive => false
  
  #Whitelist attributes which can be mass-assigned
  attr_accessible :name, :description
  attr_readonly :slug
  
  def is_admin_role?
    return slug == "admin"
  end
  
  def is_role?(value)
    return slug == value.to_s
  end
  
end
