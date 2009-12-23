require 'clearance'

class UsersController < Clearance::UsersController
  before_filter :admin_only, :only => [ :index, :show, :create, :new, :update, :edit ] if ENV['RAILS_ENV'] == 'production'
  before_filter :admin_only, :only => [ :index, :show] if ENV['RAILS_ENV'] == 'development'
  before_filter :get_user, :only => [ :edit, :update ]
  
  def index
    @users = User.find_by_hashed_id(:all)
  end
  
  def show
    @user = User.find_by_hashed_id(params[:id]) if get_user().hashed_id == params[:id]
  end
  
  def edit
    @user = User.find_by_hashed_id(params[:id]) if get_user().hashed_id == params[:id]
  end
  
  def update
    if signed_in_as_admin? && params[:user][:admin] && params[:user][:admin] == "1"
      @user.admin = true
      @user.save
    elsif signed_in_as_admin?
      @user.admin = false
      @user.save
    end
        
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User Record was successfully updated.'
        format.html { redirect_to(edit_user_url(@user)) }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  protected
  
  def get_user
    if signed_in_as_admin?
      @user = User.find_by_hashed_id(params[:id])
    elsif signed_in?
      @user = current_user
    end
  end
end