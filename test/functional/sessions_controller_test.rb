require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < ActionController::TestCase
  fixtures :users, :tenants

  def setup
    User.any_instance.stubs(:sleep).returns(nil)
  end

  def test_should_login_and_redirect
    user = users(:standard_user)
    post :create, :login => user.login, :password => 'Foobarbaz5'
    assert session[:user]
    assert_response :redirect
  end

  def test_should_fail_password_and_not_redirect
    user = users(:standard_user)
    post :create, :login => user.login, :password => 'bad password'
    assert_nil session[:user]
    assert_response :success
  end
  
  def test_should_fail_login_and_not_redirect
    post :create, :login => 'not-a-real-user', :password => 'some password'
    assert_nil session[:user]
    assert_response :success
    post :create, :login => 'not-a-real-user', :password => ''
    assert_nil session[:user]
    assert_response :success
  end
  
  def test_should_fail_login_and_not_redirect_deleted_user
    user = users(:deleted_user)
    post :create, :login => user.login, :password => 'Foobarbaz5'
    assert_nil session[:user]
    assert_response :success
  end
  
  def test_user_locked_out
    user = users(:failed_user)
    post :create, :login => user.login, :password => 'ReallySpiffy3'
    assert_nil session[:user]
    assert_response :success
  end
  
  def test_user_not_locked_out
    user = users(:almost_failed_user)
    post :create, :login => user.login, :password => 'ReallySpiffy3'
    assert session[:user]
    assert_response :redirect
  end

  def test_should_logout
    login_as :standard_user
    get :destroy
    assert_nil session[:user]
    assert_response :success
  end

  def test_should_remember_me
    user = users(:standard_user)
    post :create, :login => user.login, :password => 'Foobarbaz5', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    user = users(:standard_user)
    post :create, :login => user.login, :password => 'Foobarbaz5', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end
  
  def test_should_delete_token_on_logout
    login_as :remembered_user
    get :destroy
    assert_nil @response.cookies["auth_token"]
  end

  def test_should_login_with_cookie
    users(:remembered_user).remember_me
    @request.cookies["auth_token"] = cookie_for(:remembered_user)
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    users(:remembered_user).remember_me
    users(:remembered_user).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:remembered_user)
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    users(:standard_user).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
end
