class User < ActiveRecord::Base
  include Clearance::User
  
  def admin?
    self.admin
  end
end
