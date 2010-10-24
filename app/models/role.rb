class Role < ActiveRecord::Base
  acts_as_authorization_role # Implements ACL9's roles
end
