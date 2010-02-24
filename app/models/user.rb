require 'digest/sha2'

class User < ActiveRecord::Base
  # The User model is the basic class at the heart of the Authentication 
  # system - it handles users and their passwords

  #Required length of password
  @@password_length = 5
  #Required login length
  @@login_length = 4
  #Location of common passwords YAML array
  @@common_passwds = YAML.load_file("#{RAILS_ROOT}/lib/common_pwds.yaml")
  #Error string for a password which fails a quality test
  @@quality_failure_text = "is not strong enough. Try including a few numbers and capital letters."

  acts_as_deactivated
  has_hashed_id
  
  before_save :encrypt_password
  before_save :clear_fields # After everything is validated, we can clear out the 
                            # the intermediate fields used for the password
  before_save :clean_phone
  before_create :make_activation_code
  
  before_destroy :verify_destroy 
  
  
  has_many :privileges
  has_many :roles, :through => :privileges
  
  # Custom habtms
  has_many :experiments
  belongs_to :group

  #Whitelist attributes which can be mass-assigned
  attr_accessible :login, :email, :password, :password_confirmation, :supplied_password, :eula, :name, :phone
  attr_readonly :login
 
  validates_presence_of     :login
  validates_presence_of     :name
  validates_email           :email, :unique => true
  validates_presence_of     :supplied_password,          :if => :further_password_required?
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_changed?
  validates_length_of       :password, :within => @@password_length..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_changed?
  validates_length_of       :login,    :within => @@login_length..40
  validate                  :validate_email_can_be_changed
  validate                  :validate_password
  validates_uniqueness_of   :login, :case_sensitive => false
  validate                  :validate_eula_accepted
  validates_length_of :phone, :minimum => 10, :allow_blank => true, :allow_nil => true
  
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
  
  def password=(new_password)
    @password = new_password
    #Prevents tampering w/ password after assignment
    if @true_password == nil and !new_password.blank?
    @true_password = String.new(new_password)
    @password_changed = true
    end
  end

  def eula
    self.eula_version == EULA::CurrentVersion
  end
  
  def eula=(flag)
    truthiness = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(flag)
    self.eula_version = EULA::CurrentVersion if truthiness
  end

  def validate_email_can_be_changed
    if self.email_changed? and email_password_required?
      match = authenticate_password(@supplied_password, nil)
      errors.add("Current Password", "is required to change your email address") unless match
      return match
    end
  end

  def validate_eula_accepted
    errors.add_to_base(\
      "You must accept the Terms of Service and Privacy Policy")\
      unless eula
  end
  
  # User-entered password, temp storage
  def password
    return @password
  end
  
  def silently_update?
    return @silently_update
  end
  
  def silently_update=(value)
    @silently_update = value
  end
  
  # For use when User.cryptedpassword is being changed
  def supplied_password=(new_supplied_password)
    if @supplied_password == nil
    @supplied_password = String.new(new_supplied_password)
    end
  end
  
  # Simply returns whether @supplied_password has been set or not
  def supplied_password 
    return "supplied_password_substitute" if @supplied_password
    return nil
  end
  
  # Activates the user in the database.
  def activate
    if self.activated_at.nil? and !self.activation_code.nil? and @activated.nil?
      @activated = true
      self.activated_at = Time.now.utc
      self.activation_code = nil
      self.save!
    end
  end

  def activated?
    activation_code.nil? && !self.frozen_in_db && self.deactivated_at == nil
  end
  
  def before_deactivate
    remove_auth_tokens
  end
  
  def password_changed?
   @password_changed
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
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
  
  def generate_recover_in_process_code
    if can_reset_password?
      self.recover_in_process_code = CGI::escape(String.random_hash(login))
      @recover_in_process_code_generated = true
      self.recover_code = nil
      self.recover_requested = false
      self.save!
      return self.recover_in_process_code
    end
    return nil
  end
  
  def generate_recover_code
    self.recover_code = CGI::escape(String.random_hash(login))
    self.recover_requested_at = Time.now.utc
    self.recover_requested = true
    self.recover_in_process_code = nil
    self.save!
    return self.recover_code
   
  end
  
  def recover_in_process?
    !self.recover_in_process_code.blank? && Time.now.utc - self.recover_requested_at < @@reset_time_allowed
  end
  
  # Returns true if the user has been cleared to have their password reset
  def can_reset_password?
    self.recover_requested == true && (Time.now.utc - self.recover_requested_at) < @@reset_time_allowed
  end
  
  
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password, tmp_salt = nil, ip_address = nil)
    u = find( :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]) # need to get the salt
    u && u.authenticated?(password, tmp_salt, ip_address) ? u : nil
  end
  
  def self.locked_out?(login)
    u = find( :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]) # need to get the salt
    locked_out = false
    locked_out = u.locked_out? if !u.nil?
    return locked_out
  end
  
  #Returns if a user account is locked because of too many failures
  def locked_out?
    
    self.failure >= BigliettoConfig.failure_attemps
  end
  
    # Checks the password passed in against the crypted password
  def authenticated?(password, tmp_salt = nil, ip_address = nil)
    if @failures.nil?
      @failures = self.failure
    end
    return false unless deactivated_at.blank? && !locked_out? #Reject deleted users from authenticating, or if they have failed authenticating
    matches = authenticate_password(password, tmp_salt)
    if matches
      self.last_authenticated_at = Time.now.utc
      self.last_authenticated_ip = ip_address
      @failures = 0
      self.failure = 0;
    else
      # random time delay here to prevent dictionary attacks or 
      # guessing using comparison timing techniques
      sleep_time = 1 + (rand(300).to_f / 100)
      sleep sleep_time
      
      @failures += 1
      self.failure += 1
      self.last_failed_at = Time.now.utc
      self.last_failed_ip = ip_address
    end
    self.save!
    matches
  end

  def recently_authenticated?
    last_authenticated_at && (last_authenticated_at >= 10.seconds.ago.utc)
  end
  
  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    if salt == nil or password == nil
      raise TypeError.new("Nil not Accepted")
    end
    Digest::SHA256.hexdigest(password + salt)
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for @@remember_me_length
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  #Creates a token which can be used to login the user via cookie
  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save
  end

  #Deletes all tokens needed to login via cookie
  def forget_me
    remove_auth_tokens
    save
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
    
    # Remove the auth tokens for that user
    def verify_destroy
      remove_auth_tokens 
    end
       
    #if the user successfuly logins in, reset their failures to 0
    def reset_failures
      self.failures = 0
      self.save
    end
    
    def clear_fields
      @supplied_password = nil
      @password = nil
      @true_password = nil
      @failures = nil
      @password_changed = nil
      @recover_in_process_code_generated = nil
      self.password_confirmation = nil
    end
   
    # before filter - encrypt the password w/ the salt
    def encrypt_password
      return if @true_password.blank?
      #Check that the supplied password matches the real one and a password is required
      return false if further_password_required? && !authenticate_password(@supplied_password)
      self.salt = String.random_hash(login)
      self.crypted_password = encrypt(@true_password)
      #Set the password reset to nil (in case that's why the password was changed)
      self.recover_requested = false
      self.recover_in_process_code = nil
      @password_changed = true
      return true
    end
    
    # Returns true if
    # No crypted password has been set before
    # or further_password_require returns true
    # Mainly meant for first-time setting of the password
    def password_required?
      crypted_password.blank? || further_password_required? || (password_changed? && recover_in_process?)
    end
    
    # Returns true if
    # The crypted password is set
    # and the password has been set (meaning the user wants to change the password)
    # Mainly meant for changing the password
    def further_password_required?
      !crypted_password.blank? && !@true_password.blank? && !self.recover_in_process?
    end
    
    def email_password_required?
      !crypted_password.blank?
    end
    
    def remove_auth_tokens
      self.remember_token_expires_at = nil
      self.remember_token            = nil
    end
    
    
    # Returns true iff foo
    # the password matches the encrypted pasword
    def authenticate_password(password, tmp_salt = nil)
      return false if password.blank?
      tmp_crypted_password = crypted_password
      hashed_password = nil
      
      unless tmp_salt.blank?
        tmp_crypted_password = self.class.encrypt(crypted_password, tmp_salt)
        hashed_password = password
      else
        hashed_password = self.encrypt(password)
      end
      matches =  tmp_crypted_password == hashed_password
      matches
    end
    
    # Generates the activation code by creating a random string of letters 20 chars long
    # Test
    def make_activation_code
      self.activation_code =  CGI::escape(String.random_hash(login))
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
