class Privilege < ActiveRecord::Base
  # A Privilege represents the ability by a User to act in a certain Role within the system
  # This ties into the Authorization system, where we determine what actions a user is allowed to 
  # perform.
  # A User may only have 1 Privilege linking them to a Role, and there are strict conditions on how
  # this Privilege may be created or destroyed.
  
  has_hashed_id
  
  belongs_to :user
  belongs_to :role
  belongs_to :modified_by_user, :class_name => "User", :foreign_key => "modified_by_user_id"

  validates_presence_of :user, :role, :modified_by_user
  validate :can_assign_privilege
  validate :unique_privilege?
  
  before_validation :record_user
  before_destroy :can_destroy_privilege
  
  #Whitelist attributes which can be mass-assigned
  attr_accessible :user, :role
  
  # Does another Privilege mapping between this User and this Role exist?
  def unique_privilege?
    conditions = [];
    if self.new_record?
      conditions = ['role_id = ? and user_id = ?', self.role_id, self.user_id]
    else
      conditions = ['role_id = ? and user_id = ? and id != ?', self.role_id, self.user_id, self.id]
    end
    exists = Privilege.count(:all, :conditions=>conditions) == 0
    errors.add("privilege", "already exists") unless exists
    return exists
  end
  
  #Do we want to allow users to assign/destroy roles to themselves? 
  def can_assign_privilege
    return true
    return true if !changed?
    if current_user = User.find(self.current_user_id)
    if current_user.roles.empty?
      return true if (role.is_role?(:experimenter) || role.is_admin_role?)
    else
      current_user.roles.each do |current_user_role|
        return true if authorized_to_create_privilege(current_user_role, role)
      end
    end
    errors.add("privilege", " cannot be created by current user [" + current_user.login + "]")
    end
    return false
  end
  
  def can_destroy_privilege
    if current_user = User.find(self.current_user_id)
    current_user.roles.each do |current_user_role|
      return true if authorized_to_create_privilege(current_user_role, role)
    end
    errors.add("privilege", " cannot be destroyed by current user [" + current_user.login + "]")
    end
    return false
  end
  
  def record_user
    if self.changed? && self.current_user_id != nil 
      self.modified_by_user = User.find(:first, self.current_user_id)
    end
  end
  
  private
  
  # Uses simple rule-based chaining to determine if the given role (from the current user)
  # can create a privilege which assigns the role in question
  def authorized_to_create_privilege(acting_in_role, role_to_assign)
   if role_to_assign.is_admin_role?
       return acting_in_role.slug == "admin"
   elsif role_to_assign.is_experimenter_role?
       return acting_in_role.slug == "experiment" || acting_in_role.slug == "admin"
   end
   return false
 end
 
end
