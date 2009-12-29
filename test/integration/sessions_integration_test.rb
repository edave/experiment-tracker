require File.dirname(__FILE__) + '/../test_helper'

class SessionsIntegrationTest < ActionController::IntegrationTest
  def setup
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_protect_from_forgery
    get "/signin"
    assert_response :success
    assert_template "sessions/new.html.erb"
    body = @response.body
    token = %r{authenticity_token[^>]+value=\"(.*)\"}.match(body)[1]
    assert token

    User.any_instance.stubs(:authenticated?).returns(true)

    post '/sessions', :login => "elialfordj", :password => "swordfish"
    assert_response :unprocessable_entity

    post '/sessions', :login => "elialfordj", :password => "swordfish",
      :authenticity_token => token
    assert_response :redirect
  end
end
