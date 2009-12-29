require File.dirname(__FILE__) + '/../test_helper'
require 'pp'

class UserTest < ActiveSupport::TestCase
  fixtures :users
  
  def setup
    # Don't let failed logins slow us down
    User.any_instance.stubs(:sleep).returns(nil)
  end

  def test_new_user_defaults
    user = User.new
    
    assert_nil user.login, ""
    assert_nil user.email, ""
    assert_nil user.salt
    assert_nil user.activated_at
    assert_nil user.crypted_password
    assert_nil user.remember_token
    assert_nil user.remember_token_expires_at
    
    assert_nil user.last_authenticated_at
    assert_nil user.last_authenticated_ip
    
    assert_nil user.activation_code
    assert_nil user.activated_at
    
    assert_nil user.deactivated_at
    assert     !user.frozen_in_db
    
    assert_equal user.recover_requested, false
    assert_nil user.recover_requested_at
    assert_nil user.recover_code
    assert_nil user.recover_in_process_code
    
    assert_equal user.failure, 0
    assert user.eula_version, 0
    assert !user.eula
    
    assert_equal user.lock_version, 0
  end
  
  def test_creates_hashed_id
    user = User.new(:login => "new_user",
                    :email => "test@domain.com",
                    :password => "Foo_password3",
                    :password_confirmation => "Foo_password3",
                    :eula => true)

    assert user.valid?
    user.save!
    user.reload
    assert_equal user.hashed_id, user.id.to_hashed_id
  end
  
  def test_only_updates_given_attribute
     user = User.new(:login => "new_user",
                    :email => "test@domain.com",
                    :password => "Foo_password3",
                    :password_confirmation => "Foo_password3",
                    :failure => 0,
                    :eula => true)

    assert user.valid?
    user.save!
    user.reload
    assert_equal user.hashed_id, user.id.to_hashed_id
    assert_equal user.failure, 0
    user.failure = 3 # just another random attr to test
    user.update_single_attribute(:hashed_id, 1234567890) #again, testing any variable
    user.reload
    assert_equal user.hashed_id, 1234567890
    assert_equal user.failure, 0
    
  end
  
  def test_empty_validation
    user = User.new

    assert !user.valid?
    assert user.errors.invalid?(:login)
    assert user.errors.invalid?(:email)
    assert user.errors.invalid?(:password)
    assert !user.errors.invalid?(:password_confirmation)
    assert !user.errors.invalid?(:supplied_password)
    assert user.errors[:base] =~ /Terms of Service/
  end
  
  def test_new_user_passes_validation
    user = User.new(:login => "new_user",
                    :email => "test@domain.com",
                    :password => "Foo_password3",
                    :password_confirmation => "Foo_password3",
                    :eula => true)

    assert user.valid?
  end
  
  def test_new_user_fails_validation
    user = User.new(:login => "a",
                    :email => "blankdomain.com",
                    :password => "ppps",
                    :password_confirmation => "doesn't match")
    assert !user.valid?
    assert user.password_robustness_level > 1
    assert user.errors.invalid?(:login)
    assert user.errors.invalid?(:email)
    assert user.errors.invalid?(:password)
    assert user.errors[:base] =~ /Terms of Service/
    password_errors = 1
    
    assert_equal I18n.translate('activerecord.errors.messages')[:confirmation],
                 user.errors.on(:password)[password_errors]
    
    assert !user.errors.invalid?(:password_confirmation)
    assert !user.errors.invalid?(:supplied_password)
    
    user.password_confirmation = 'ppps'
    assert !user.valid?
    if user.password_robustness_level > 0
      assert_equal "is not strong enough. Try including a few numbers and capital letters.", user.errors.on(:password)[password_errors]
      password_errors -= 1
    end
  end
  
  def test_should_create_user
    #pp "Create User"
    assert_difference User, :count do
      user = create_user
      #pp "New: #{!user.new_record?}"
      assert !user.new_record?, "#{user.login} - #{user.errors.full_messages.to_sentence}"
    end
    
  end

  def test_should_set_eula_version
    user = create_user # passes true for :eula
    assert_equal user.eula_version, EULA::CurrentVersion
  end
  
  def test_should_not_set_eula_version_if_unchecked
    user = create_user(:eula => nil)
    assert_equal user.eula_version, 0
  end
  
  def test_no_change_password
    user =  users(:standard_user)
   
    #We're not supplying the original password, so nothing should change
    user.update_attributes(:password => 'new password foo', :password_confirmation => 'new password foo')
    assert_equal nil, User.authenticate(user.login, 'new password foo')
    
    #Supplying an incorrect password
    user.reload
    user.update_attributes(:password => 'new password bar', :password_confirmation => 'new password bar', :supplied_password => 'foo')
    assert_equal nil, User.authenticate(user.login, 'new password bar')
      
    #Supplying a weak password
    user.reload
    user.update_attributes(:password => 'ilikeweakpasswords', :password_confirmation => 'ilikeweakpasswords', :supplied_password => 'Foobarbaz5')
    assert_equal nil, User.authenticate(user.login, 'ilikeweakpasswords')
    
    #Supplying a common password
    user.reload
    user.update_attributes(:password => 'Abc123', :password_confirmation => 'Abc123', :supplied_password => 'Foobarbaz5')
    assert_equal nil, User.authenticate(user.login, 'Abc123')
  end
  
  def test_change_password
    #Now we're doing it correctly
    user =  users(:standard_user)
    user.update_attributes(:password => 'nEw password#3', :password_confirmation => 'nEw password#3', :supplied_password => 'Foobarbaz5')
    assert_not_equal user.crypted_password, 'nEw password#3'
    assert_equal users(:standard_user), User.authenticate(user.login, 'nEw password#3')  
  end
  
  def test_should_not_access_passwords
    #Now we're doing it correctly
    user =  users(:standard_user)
    user.supplied_password = 'Foobarbaz5'
    assert_not_equal user.supplied_password, 'Foobarbaz5'
    user.update_attributes(:password => 'nEw password#3', :password_confirmation => 'nEw password#3')
    assert_nil user.supplied_password
    assert_nil user.password
    assert_nil user.password_confirmation
  end

  def test_should_not_rehash_password
    user = users(:standard_user)
    assert_equal users(:standard_user), User.authenticate(user.login, 'Foobarbaz5')
    user.update_attributes(:email => 'foo_bar_baz@email.com')
    user.save
    assert_equal users(:standard_user), User.authenticate(user.login, 'Foobarbaz5')
  end
  
  def test_change_email
    user = users(:standard_user)
    user.update_attributes(:email => "snazzynew@email.com", :supplied_password => "Foobarbaz5")
    assert user.save
    
    user.reload
    user.update_attributes(:email => "snazzynew2@email.com")
    assert !user.save
    user.update_attributes(:email => "snazzynew3@email.com", :supplied_password => "")
    assert !user.save
    user.update_attributes(:email => "snazzynew4@email.com", :supplied_password => nil)
    assert !user.save
    user.update_attributes(:email => "snazzynew5@email.com", :supplied_password => "wrong password")
    assert !user.save
    
    
  end

  def test_should_correctly_authenticate_user
    user = users(:standard_user)
    assert_equal user, User.authenticate(user.login, 'Foobarbaz5')
    assert_equal nil, User.authenticate(user.login, 'not_a_password')
    assert_equal nil, User.authenticate(user.login, user.crypted_password)
    assert_equal nil, User.authenticate(user.login, '')
    assert !User.authenticate(user.login, nil)
    assert_equal nil, User.authenticate(users(:deleted_user).login, 'Foobarbaz5')
    
    user_2 = users(:almost_failed_user)
    assert_equal user_2, User.authenticate(user_2.login, 'ReallySpiffy3')
    
    user_failed = users(:failed_user)
    assert_nil User.authenticate(user_failed.login, 'ReallySpiffy3')
 end
 
 def test_failures

   user = users(:standard_user)
    assert_equal user, User.authenticate(user.login, 'Foobarbaz5')
    assert_equal nil, User.authenticate(user.login, 'not_a_password')
    assert_equal nil, User.authenticate(user.login, user.crypted_password)
    assert_equal nil, User.authenticate(user.login, '')
    
    user.reload
    assert_equal user.failure, 3
    assert_equal user, User.authenticate(user.login, 'Foobarbaz5')
    user.reload
    
    assert_equal user.failure, 0
    
    user_2 = users(:almost_failed_user)
    assert_equal user_2, User.authenticate(user_2.login, 'ReallySpiffy3')
    user_2.reload
    assert_equal user_2.failure, 0
   
    user_failed = users(:failed_user)
    assert_nil User.authenticate(user_failed.login, 'ReallySpiffy3')
    assert_not_equal user_failed.failure, 0
  end
  
  def test_locked_out
    user = users(:standard_user)
    assert !User.locked_out?(user.login)
    
    user_2 = users(:almost_failed_user)
    assert !User.locked_out?(user_2.login)
   
    user_failed = users(:failed_user)
    assert User.locked_out?(user_failed.login)
  end

  def test_should_not_delay_on_successful_login
    User.any_instance.expects(:sleep).never
    user = users(:standard_user)
    assert_equal user, User.authenticate(user.login, 'Foobarbaz5')
  end
  
  def test_should_delay_on_failed_login
    User.any_instance.expects(:sleep).once
    user = users(:standard_user)
    assert_equal nil, User.authenticate(user.login, 'not_a_password')
  end
  
  def test_should_correctly_authenticate_user_with_temp_salt
    user = users(:standard_user)
    temp_salt = String.random_hash
    temp_salt2 = String.random_hash
    hashed_password = User.encrypt('Foobarbaz5', user.salt)
    encrypted_password = User.encrypt(hashed_password, temp_salt)
    assert_equal nil, User.authenticate(user.login, 'Foobarbaz5', temp_salt)
    assert_equal nil, User.authenticate(user.login, hashed_password, temp_salt)
    assert_equal nil, User.authenticate(user.login, encrypted_password, temp_salt2)
    assert_equal user, User.authenticate(user.login, encrypted_password, temp_salt)
  end

  def test_should_not_authenticate_failed_user
    user = users(:failed_user)
    assert_equal nil, User.authenticate(user.login, 'ReallySpiffy3')
    
    user_2 = users(:almost_failed_user)
    assert_equal nil, User.authenticate(user_2.login, 'blahblahblah')
    assert_equal nil, User.authenticate(user_2.login, 'ReallySpiffy3')
   
  end

  def test_recover_code
    user = users(:standard_user)
    
    recover_code = user.generate_recover_code
    assert_not_nil user.recover_code
    assert_equal recover_code, user.recover_code
    assert_not_nil user.recover_requested_at
    assert user.recover_requested
    assert !user.recover_in_process?
    assert user.can_reset_password?
  end
  
  def test_recover_in_process
    user = users(:standard_user)
    user.generate_recover_code
    recover_in_process = user.generate_recover_in_process_code
    assert_not_nil user.recover_in_process_code
    assert_nil user.generate_recover_in_process_code
    assert_equal recover_in_process, user.recover_in_process_code
    assert_equal nil, user.recover_code
    assert !user.recover_requested
    assert user.recover_in_process?
    assert !user.can_reset_password?
  end
  
  def test_reset_password
    user = users(:standard_user)
    assert !user.recover_in_process?
    assert !user.can_reset_password?
    
    assert user.generate_recover_code
    assert user.can_reset_password?
    
    assert user.generate_recover_in_process_code
    assert user.recover_in_process?
    assert !user.can_reset_password?
    
    user.reload
    assert user.recover_in_process?
    assert !user.can_reset_password?
    
    # Test that we still are restricting the length
    assert !user.update_attributes(:password => "1")
    assert_nil User.authenticate(user.login, '1') 
    # Test that we require a confirmation
    assert !user.update_attributes(:password => "PerfectlyLeg1tPassword", :password_confirmation => "different_confirmation")
    assert_nil User.authenticate(user.login, 'PerfectlyLeg1tPassword') 
    if user.password_robustness_level > 0
      # Test that the robustness check is active
      assert !user.update_attributes(:password => 'abcdefghijk', :password_confirmation => 'abcdefghijk')
      assert_nil User.authenticate(user.login, 'abcdefghijk') 
    end
    
    user.reload
    assert user.update_attributes(:password => 'PerfectlyLeg1tPassword', :password_confirmation => 'PerfectlyLeg1tPassword')
    assert_equal users(:standard_user), User.authenticate(user.login, 'PerfectlyLeg1tPassword') 
    
    user.reload
    assert !user.recover_requested
    assert !user.recover_in_process?
    assert !user.can_reset_password?
    assert !user.update_attributes(:password => 'another new password', :password_confirmation => 'another new password')
    
    assert_equal nil, User.authenticate(user.login, 'another new password') 
    assert_equal users(:standard_user), User.authenticate(user.login, 'PerfectlyLeg1tPassword')
  end
  
  def test_reset_password_expired
    user = users(:standard_user)
    user.generate_recover_code
    user.generate_recover_in_process_code
    user.recover_requested_at = Time.now - 1.day - 1.hour
    user.save
    user.reload
    user.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    
    assert_not_equal users(:standard_user), User.authenticate(user.login, 'new password') 
  
  end

  def test_should_set_remember_token
    users(:standard_user).remember_me
    assert_not_nil users(:standard_user).remember_token
    assert_not_nil users(:standard_user).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:standard_user).remember_me
    assert_not_nil users(:standard_user).remember_token
    users(:standard_user).forget_me
    assert_nil users(:standard_user).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:standard_user).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:standard_user).remember_token
    assert_not_nil users(:standard_user).remember_token_expires_at
    assert users(:standard_user).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:standard_user).remember_me_until time
    assert_not_nil users(:standard_user).remember_token
    assert_not_nil users(:standard_user).remember_token_expires_at
    assert_equal users(:standard_user).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    assert !users(:standard_user).remember_token?
    users(:standard_user).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:standard_user).remember_token
    assert_not_nil users(:standard_user).remember_token_expires_at
    assert users(:standard_user).remember_token_expires_at.between?(before, after)
    assert users(:standard_user).remember_token?
  end
  
  def test_should_deactivate_user
    stub_encryption_keys
    user = users(:standard_user)
    
    assert_nil user.deactivated_at
    assert !user.recently_deactivated?
    assert !user.deactivated?
    assert !user.frozen_in_db
    
    time = 1.week.from_now.utc
    users(:standard_user).remember_me_until time
    user.destroy
    assert !user.frozen?
    
    user.deactivate!
    assert user.deactivated?
    assert user.recently_deactivated?
    assert user.deactivated_at.between?(2.seconds.ago.utc, 2.seconds.from_now.utc)
    assert user.frozen_in_db?
    #assert user.frozen?
    
    #user2 = User.find_by_id(user.id)
    user.reload
    assert !user.frozen?
    assert user.deactivated?
    assert user.frozen_in_db?
    assert_not_nil user.deactivated_at
    
    assert_nil User.authenticate(user.login, 'Foobarbaz5')
    
    user2 = User.find(user.id)
    assert user2.deactivated?
    assert user.frozen_in_db?
    assert_not_nil user.deactivated_at
    
    user2.frozen_in_db = false
    assert !user.save
    
    user2.reload
    user2.email = "newemail123@example.com"
    assert !user.save
    
    
    #assert user.deleted_at.between?(2.seconds.ago.utc, 2.seconds.from_now.utc)
    #assert_nil user.remember_token
    #assert_nil user.remember_token_expires_at
    user.destroy
    assert user.frozen?
    assert user.deactivated?
    assert_not_nil user.deactivated_at
    assert user.frozen_in_db?
    assert_nil User.authenticate(user.login, 'Foobarbaz5')
  end

  def test_should_activate_user
    user = users(:not_activated_user)
    user.activation_code = "foobarbaz"
    user.activate
    assert user.recently_activated?
    user.reload
    assert_equal user.activation_code, nil
    
    #assert user.activated_at.between?(2.seconds.ago.utc, 2.seconds.from_now.utc)
    assert user.activated?
  end
  
  protected
    def create_user(options = {})
      User.create({ :login => 'create_me_a_user', :email => 'squire@example.com', :password => 'Mieeerrr33', :password_confirmation => 'Mieeerrr33', :eula => true }.merge(options))
    end
end
