class User < ActiveRecord::Base
  include Clearance::User
  
  has_many :experiments
  
  def admin?
    self.admin
  end
end
