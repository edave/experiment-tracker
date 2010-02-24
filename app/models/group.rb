class Group < ActiveRecord::Base
  acts_as_deactivated
  has_hashed_id
  
  has_many :users
  has_many :experiments, :through => :users
  
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
