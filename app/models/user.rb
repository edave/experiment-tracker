class User < ObfuscatedRecord
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :user_name, :name, :phone
  attr_readonly :user_name
  
  #Required length of password
  @@password_length = 5
  #Required login length
  @@login_length = 4
  #Location of common passwords YAML array
  @@common_passwds = YAML.load_file(Rails.root.join("lib", "common_pwds.yaml"))
  #Error string for a password which fails a quality test
  @@quality_failure_text = "is not strong enough. Try including a few numbers and capital letters."

  before_save :clear_fields # After everything is validated, we can clear out the 
                            # the intermediate fields used for the password
  before_save :clean_phone
    
  # Custom habtms
  has_many :experiments
  belongs_to :group

  validates_presence_of     :user_name
  validates_presence_of     :name
  #validates_email           :email, :unique => true
  #validates_presence_of     :supplied_password,          :if => :further_password_required?
  #validates_presence_of     :password,                   :if => :password_required?
  #validates_presence_of     :password_confirmation,      :if => :password_changed?
  #validates_length_of       :password, :within => @@password_length..40, :if => :password_required?
  #validates_confirmation_of :password,                   :if => :password_changed?
  validates_length_of        :user_name,    :within => @@login_length..40
  #validate                  :validate_email_can_be_changed
  #validate                  :validate_password
  validates_uniqueness_of    :user_name, :case_sensitive => false
  #validates_length_of :phone, :minimum => 10, :allow_blank => true, :allow_nil => true
  
  def clean_phone
    unless self.phone.nil?
     self.phone = self.phone.gsub(/[^\d]/,'')
    end
  end
  
  # has_role? simply needs to return true or false whether a user has a role or not.  
  def has_role?(role_in_question)
    @roles_list ||= self.roles.collect(&:slug).collect(&:downcase)
    (@roles_list.include?(role_in_question.to_s.downcase))
  end
   
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
  
   def password_robustness_level
    return @@password_robustness_level
  end
  
  def reload
    super #Call the ActiveRecord.reload
    # Now clear out all of our extra stuff
    clear_fields
  end
  
  # def logout
  #   forget_me if logged_in?
  #   cookies.delete :auth_token
  #   reset_session
  # end

  private
    #Length of time allowed after a reset has been requested to reset password
    @@reset_time_allowed = 1.day
    #Length of time that "remember me"/cookie login is valid
    @@remember_me_length = 2.weeks
    
    #Level of password quality and robustness
    # Each level uses rules from the previous level(s)
    # 0 - absolutely no checks on password length or quality, Don't Use!
    # 1 - At least 1 number/symbol
    # 2 - Case senstivity
    @@password_robustness_level = 2
    
    # Checks password against common list of passwords and custom list of passwords
    @@filter_common_passwords = true
    
    @supplied_password = nil
    @password = nil
    @true_password = nil
    @silently_update = nil
    @failures = nil
    @activated = nil
    @password_changed = nil
    @recover_in_process_code_generated = nil
    
     def clear_fields
      @supplied_password = nil
      @password = nil
      @true_password = nil
      @failures = nil
      @password_changed = nil
      @recover_in_process_code_generated = nil
      self.password_confirmation = nil
    end
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
