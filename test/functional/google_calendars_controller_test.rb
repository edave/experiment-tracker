require 'test_helper'

class GoogleCalendarsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:google_calendars)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create google_calendar" do
    assert_difference('GoogleCalendar.count') do
      post :create, :google_calendar => { }
    end

    assert_redirected_to google_calendar_path(assigns(:google_calendar))
  end

  test "should show google_calendar" do
    get :show, :id => google_calendars(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => google_calendars(:one).to_param
    assert_response :success
  end

  test "should update google_calendar" do
    put :update, :id => google_calendars(:one).to_param, :google_calendar => { }
    assert_redirected_to google_calendar_path(assigns(:google_calendar))
  end

  test "should destroy google_calendar" do
    assert_difference('GoogleCalendar.count', -1) do
      delete :destroy, :id => google_calendars(:one).to_param
    end

    assert_redirected_to google_calendars_path
  end
end
