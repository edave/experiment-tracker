class User < ObfuscatedRecord
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :timeoutable

  # Add ACL9's support for roles/authorization
  acts_as_authorization_subject  :association_name => :roles

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :user_name, :name, :phone
  attr_readonly :user_name
  
  #Location of common passwords YAML array
  @@common_passwds = YAML.load_file(Rails.root.join("lib", "common_pwds.yaml"))
  #Error string for a password which fails a quality test
  @@quality_failure_text = "is not strong enough. Try including a few numbers and capital letters."

  before_save :clean_phone
  
  #has_many :privileges, :dependent => :destroy
  #has_many :roles, :through => :privileges  
  
  # Custom habtms
  has_many :experiments
  belongs_to :group

  validates_presence_of     :user_name
  validates_presence_of     :name
  #validates_length_of        :user_name,    :within => @@login_length..40
  validates_uniqueness_of    :user_name, :case_sensitive => false
  #validates_length_of :phone, :minimum => 10, :allow_blank => true, :allow_nil => true
  
  def clean_phone
    unless self.phone.nil?
     self.phone = self.phone.gsub(/[^\d]/,'')
    end
  end
  
  # has_role? simply needs to return true or false whether a user has a role or not.  
  #def has_role?(role_sym)
  #  @roles_list ||= self.roles.collect(&:slug).collect(&:underscore).collect(&:to_sym)
  #  @roles_list.any? { |r| r == role_sym }
  #end
   
  def validate_password
    if password_required?
      #pp "#{self.login} - #{self.password}"
      quality =  password_quality_passes?(self.password)
      not_common = common_password_check?(self.password)
      # Do not allow usernames and passwords to be identical
      not_same = (login.to_s.downcase != self.password.to_s.downcase)
      #pp "Passes: #{passes}"
      errors.add("password", @@quality_failure_text) unless quality
      errors.add("password", "is too common, try something else.") unless not_common
      errors.add("password", "cannot be the same as the login.") unless not_same
      #Rails.logger(errors)
      return (quality and not_common and not_same)
    end
   return true
  end
  
  private
   # Checks password against common list of passwords and custom list of passwords
    @@filter_common_passwords = true
    
       # Performs quality checks upon password
    def password_quality_passes?(password)
     password_regexp = ""
     passes_regexp_test = true
     # Full- ^.*(?=\w*\d)(?=\w*[a-z])(?=\w*[A-Z]).*$
     if @@password_robustness_level >= 2
       password_regexp += '(?=.*[a-z])(?=.*[A-Z])'
       
     end
     if  @@password_robustness_level >= 1
        password_regexp += '(?=.*\d)'
     end
     if  @@password_robustness_level >= 1
        #password_regexp += "{#{@@password_length},40}"
        quality_check = Regexp.new('^.*' + password_regexp + '.*$')
        #pp quality_check
        passes_regexp_test = (quality_check.match(password) != nil)
     end
   
     return passes_regexp_test
    end
    
   #Tests to see if the password is in a common list of passwords
    # returns true if the password does _not_ match any
    def common_password_check?(password)
      if @@filter_common_passwords && !password.nil?
        return !@@common_passwds.include?(password.downcase)
     end
    end
end
