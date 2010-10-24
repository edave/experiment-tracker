class Group < ObfuscatedRecord
  has_many :users
  has_many :experiments, :through => :users
     
  # ACL9 authorization support
  #acts_as_authorization_object
  
  
  # Validations
  validates_presence_of     :name
  
  validates_uniqueness_of   :logo_file_name
  validates_uniqueness_of   :name, :case_sensitive => false
  
  def open_experiments
    open_exps = Array.new
    experiments.each do |exp|
      open_exps << exp if exp.open?
    end
    return open_exps
  end
end
