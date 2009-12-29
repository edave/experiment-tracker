require File.dirname(__FILE__) + '/../test_helper.rb'
require 'users_controller'
require 'pp'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UserControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper
  fixtures :users, :tenants, :privileges, :roles

  def assert_change(obj, method)
    initial = obj.send(method)
    yield
    assert (initial != obj.send(method))
  end
  
  def assert_no_change(obj, method)
    initial = obj.send(method)
    yield
    assert (initial == obj.send(method))
  end


  def setup
    @controller = UserController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    User.any_instance.stubs(:sleep).returns(nil)
  end
  
  def test_should_edit
    user = login
    
    get :edit, :id => user.hashed_id
    
    assert_response :success
    assert_template "user/edit"
  end
  
  def test_should_not_edit
    #Not Logged In
    all_users = User.find(:all)
    all_users.each do |user|
      get :edit, :id => user.hashed_id
      assert_response :redirect
    end
    #Logged In, but trying to access another user
    logged_in_user = login
    all_users.each do |user|
      if user.id != logged_in_user.id 
      get :edit, :id => user.hashed_id
      assert_response :redirect
      end
    end
  end
  
  def test_should_show
    user = login :admin
    
    get :show, :id => user.hashed_id
    assert_response :success
    assert_template "user/show"

    get :show, :id => user.hashed_id, :format => "xml"
    assert_response :success
  end

  def test_should_not_show
    #Not logged in at all
    all_users = User.find(:all)
    all_users.each do |user|
      get :show, :id => user.hashed_id
      assert_response :redirect

      get :show, :id => user.hashed_id, :format => "xml"
      assert_response :unauthorized
    end
    #Logged In, but trying to accesss another user
    logged_in_user = login
    all_users.each do |user|
      if user.id != logged_in_user.id 
      get :show, :id => user.hashed_id
      assert_response :redirect

      get :show, :id => user.hashed_id, :format => "xml"
      assert_response :unauthorized
      end
    end
  end
  
  def test_should_update
    user = login
    assert_change user, :email do
        put :update, :id => user.hashed_id, :user => {:email => "new3fa@email.com", :supplied_password =>"Foobarbaz5"}
        assert_response :success
        assert_template "user/edit"
        user.reload
     end
     
     put :update, :id => user.hashed_id, :user => {:password=>"newfunPassword3", :password_confirmation=>"newfunPassword3", :supplied_password=>"Foobarbaz5"}
     assert_response :success
     assert_template "user/edit"
     assert_not_nil User.authenticate(user.login, 'newfunPassword3')
  end
  
  def test_should_not_update
    #Not logged in at all
    all_users = User.find(:all)
    all_users.each do |user|
        assert_no_change user, :email do
        put :update, :id => user.hashed_id, :user => {:email => "new@email.com"}
        assert_response :redirect
        end
        assert_no_change user, :email do
        put :update, :id => user.hashed_id, :user => {:email => "new@email.com", :password=>"newfunpassword3", :password_confirmation=>"newfunpassword3"}
        assert_response :redirect
        end
        assert_no_change user, :password do
        put :update, :id => user.hashed_id, :user => {:email => "new@email.com", :password=>"newfunpassword3", :password_confirmation=>"newfunpassword3"}
        assert_response :redirect
        
    end
      assert_no_change user, :login do
        put :update, :id => user.hashed_id, :user => {:login => "foooob", :email => "new@email.com", :password=>"newfunpassword3", :password_confirmation=>"newfunpassword3"}
        assert_response :redirect
      end
    end
    #Logged In, but trying to accesss another user
    logged_in_user = login
    all_users.each do |user|
      if user.id != logged_in_user.id 
      assert_no_change user, :email do
        put :update, :id => user.hashed_id, :user => {:email => "new@email.com", :password=>"newfunpassword3", :password_confirmation=>"newfunpassword3"}
        assert_response :redirect
      end
       assert_no_change user, :password do
        put :update, :id => user.hashed_id, :user => {:email => "new@email.com", :password=>"newfunpassword3", :password_confirmation=>"newfunpassword3"}
        assert_response :redirect
        #assert_template 'sessions/denied'
        
      end
      assert_no_change user, :login do
        put :update, :id => user.hashed_id, :user => {:login => "foooob", :email => "new@email.com", :password=>"newfunpassword3", :password_confirmation=>"newfunpassword3"}
        assert_response :redirect
        #assert_template 'sessions/denied'
        
      end
      end
    end
  end

# We'll revisit these tests when we revisit the deactivation action,
# currently disabled.
=begin
  def test_should_deactivate
    user = login
    assert_change user, :deleted_at do
        put :destroy, :id => user.id
        assert_response :success
        user.reload
        assert user.deleted?
    end
  end
  
  def test_should_not_deactivate
        #Not logged in at all
    all_users = User.find(:all)
    all_users.each do |user|
        already_deleted = user.deleted?
        put :destroy, :id => user.id
        assert_response :redirect
        assert !user.recently_deleted?
        if already_deleted
          assert user.deleted?
        else
          assert !user.deleted?
        end
        
    end
    #Logged In, but trying to accesss another user
    logged_in_user = login
    all_users.each do |user|
      if user.id != logged_in_user.id 
      assert_no_change user, :deleted? do
        put :destroy, :id => user.id
        assert_response :redirect
        assert !user.recently_deleted?
        user.reload
        #assert !user.deleted?
      end
      end
    end
  end
=end

  def test_should_allow_signup
    assert_difference User, :count do
      create_user({}, {:id => tenants(:standard_user).invitation_key})
    end
    assert_redirected_to "/dashboard/first_steps"
  end

  def test_should_require_login_on_signup
    assert_no_difference User, :count do
      create_user({:login => nil}, 
                  {:id => tenants(:standard_user).invitation_key})
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_invitation_key_on_signup
    create_user(:password => nil)
    assert_response :redirect
    assert_match /You must have an invitation key/, flash[:error]
  end

  def test_should_require_password_on_signup
    assert_no_difference User, :count do
      create_user({:password => nil}, 
                  {:id => tenants(:standard_user).invitation_key})
      assert_response :success
      assert assigns(:user).errors.on(:password)
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference User, :count do
      create_user({:password_confirmation => nil}, 
                  {:id => tenants(:standard_user).invitation_key})
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference User, :count do
      create_user({:email => nil}, 
                  {:id => tenants(:standard_user).invitation_key})
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end
  
  def test_should_send_reset
    
    user = users(:standard_user)
    get :send_reset, :email => user.email, :login => user.login
    assert_response :success
    assert_nil flash[:notice]
    
    user.reload
    assert_not_nil user.recover_code
    assert user.recover_requested
    assert !user.recover_in_process?
    assert user.can_reset_password?
  end
  
  def test_should_not_send_reset
    user = users(:standard_user)
    
    get :send_reset, :email => "noemail", :login => user.login
    assert_response :redirect
    assert_not_nil flash[:error]
    
    get :send_reset, :email => user.email, :login => 'nouser'
    assert_response :redirect
    assert_not_nil flash[:error]
    
    get :send_reset, :email => "noemail", :login => 'nouser'
    assert_response :redirect
    assert_not_nil flash[:error]
    
  end
  
  def test_user_reset_start
    get :reset_password, :recover_code => "no user's recover code"
    assert_response :success
    assert_equal "Recover code not found", flash[:error]
    
    user = users(:standard_user)
    get :send_reset, :email => user.email, :login => user.login
    user.reload
    get :reset_password, :email => user.email, :recover_code => user.recover_code
    assert_response :success
    user.reload
    assert_not_nil user.recover_in_process_code
    assert_equal nil, user.recover_code
    assert !user.recover_requested
    assert user.recover_in_process?  
  end
  
  def test_user_reset_process
    user = users(:standard_user)
    get :send_reset, :email => user.email, :login => user.login
    assert_response :success
    assert flash.empty?, flash.inspect

    user.reload
    get :reset_password, :recover_code => user.recover_code, :email => user.email
    assert_response :success
    assert flash.empty?, flash.inspect

    user.reload
    post :submit_reset_password, :login => user.login, :email => user.email, :recover_in_process_code => "Quxcdrcar5",
        :user => { :login => user.login,  
        :password => 'theGreatq2x', :password_confirmation => 'theGreatq2x' }
    
    user.reload
    assert_response :success
    assert_equal flash[:error], "User account not found"
    assert_not_equal flash[:notice], "Your password was changed"
    
    assert_nil User.authenticate(user.login, 'thegreatqux')
    assert_equal user, User.authenticate(user.login, 'Foobarbaz5')
    
    # We must repeate the password reset process from step one because the process
    # locks out subsequent submit_reset_password attempts
    get :send_reset, :email => user.email, :login => user.login
    assert_response :success
    assert flash.empty?, flash.inspect
    user.reload
    get :reset_password, :recover_code => user.recover_code, :email => user.email
    assert_response :success
    assert flash.empty?, flash.inspect
    user.reload
    
    post :submit_reset_password, :login => user.login, :email => user.email, :recover_in_process_code => user.recover_in_process_code,
        :password => 'neWpassw0rdtest', :password_confirmation => 'neWpassw0rdtest'
        
    assert_response :success
    #pp "Submit flash: #{flash}"
    #pp flash
    
    assert_nil flash[:error]
    assert_equal flash[:notice], "Your password was changed"
    user.reload
    
    assert_nil User.authenticate(user.login, 'Foobarbaz5')
    assert_equal user, User.authenticate(user.login, 'neWpassw0rdtest')
  
    assert !user.recover_requested
    assert !user.recover_in_process?
    assert !user.can_reset_password?
    
    assert_equal user, User.authenticate(user.login, 'neWpassw0rdtest')
    assert_nil User.authenticate(user.login, 'Foobarbaz5')
  end

  protected
    def create_user(user_options={}, other_options={})
      post :create, {
        :user => { :login => 'quire', :email => 'quire@example.com', 
                   :password => 'Mieeerrr33', 
                   :password_confirmation => 'Mieeerrr33',
                   :eula => "1"
                 }.merge(user_options),
      }.merge(other_options)
    end
end
