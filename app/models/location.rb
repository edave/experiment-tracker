class Location < ObfuscatedRecord
  has_many :experiments
  validates_presence_of :building
  validates_presence_of :room
  validates_uniqueness_of :room, :scope => :building
  
  # ACL9 authorization support
  acts_as_authorization_object
  
  def url
    return "http://whereis.mit.edu/?selection=#{building}&zoom=16"
  end
  
  def human_location
    return "Building #{building}-#{room}"
  end
  
end
